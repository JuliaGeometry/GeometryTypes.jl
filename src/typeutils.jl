
"""
This is a terrible function. But is there any other way to reliable get the
abstract supertype of an arbitrary type hierarchy without loosing performance?
"""
@generated function go_abstract{T<:AbstractGeometry}(::Type{T})
    ff = T
    while ff.name.name != :AbstractGeometry
       ff = supertype(ff)
    end
    :($ff)
end

@generated function eltype_or{T<:GeometryPrimitive}(::Type{T}, OR)
    ET = go_abstract(T).parameters[2]
    if isa(ET, TypeVar)
        return :(OR)
    else
        return :($ET)
    end
end
@generated function ndims_or{T<:GeometryPrimitive}(::Type{T}, OR)
    N = go_abstract(T).parameters[1]
    if isa(N, TypeVar)
        return :(OR)
    else
        return :($N)
    end
end

function Base.eltype{T<:AbstractGeometry}(x::Type{T})
    eltype_or(T, Any)
end
@generated function Base.ndims{T<:AbstractGeometry}(x::Type{T})
    N = go_abstract(T).parameters[1]
    isa(N, TypeVar) && error("Ndims not given for type $T")
    :($N)
end

Base.eltype{N, T}(x::AbstractGeometry{N, T}) = T
Base.ndims{N, T}(x::AbstractGeometry{N, T}) = N

Base.eltype{T}(::Type{AFG{T}}) = T
Base.eltype{FG <: AFG}(::Type{FG}) = eltype(supertype(FG))
Base.eltype(fg::AFG) = eltype(typeof(fg))
Base.length(fg::AFG) = length(vertices(fg))
nvertices(fg::AFG) = length(fg)
nvertices{n, T}(s::Type{Simplex{n, T}}) = n
nvertices{N,T}(::Type{HyperCube{N,T}}) = 2^N
nvertices{N,T}(::Type{HyperRectangle{N,T}}) = 2^N
nvertices(s::AbstractGeometry) = nvertices(typeof(s))

spacedim(s) = length(eltype(s))
spacedim{N,T}(c::HyperCube{N,T}) = N
numtype(s) = eltype(eltype(s))
numtype{N,T}(c::HyperCube{N,T}) = T

Base.push!(fl::AFG, pt) = (push!(vertices(fl), pt); fl)
Base.copy{FG <: AFG}(fl::FG) = FG(copy(vertices(fl)))
push(fl::AFG, pt) = push!(copy(fl), pt)

vertices(s::Simplex) = s._
standard_cube_vertices(::Type{Val{1}}) = [Vec(-1), Vec(1)]
_vcat(v1,v2) = Vec(Tuple(v1)..., Tuple(v2)...)
function _combine_vcat(arr1, arr2)
    T = typeof(_vcat(first(arr1), first(arr2)))
    ret = T[]
    for v in arr1, w in arr2
        push!(ret, _vcat(v,w))
    end
    ret
end

@generated function standard_cube_vertices{N}(::Type{Val{N}})
    @assert N::Int > 0
    quote
        vert_last = standard_cube_vertices($(Val{N-1}))
        vert_1 = standard_cube_vertices(Val{1})
        _combine_vcat(vert_1, vert_last)
    end
end

@generated function vertices{N,T}(r::HyperRectangle{N,T})
    ret_type = NTuple{(2^N), Vec{N,float(T)}}
    quote
        o = origin(r)
        v = 0.5*widths(r)
        f(sv) = o + sv .* v
        tuple(map(f, standard_cube_vertices(Val{N}))...)::$ret_type
    end
end

vertices(c::HyperCube) = vertices(convert(HyperRectangle, c))
vertices(s::AbstractConvexHull) = s._

vertexmat(s::AbstractGeometry) = Mat(map(Tuple, vertices(s)))
function vertexmat(s::AbstractFlexibleGeometry)
    tuptup = tuple(map(Tuple, vertices(s))...)
    Mat(tuptup) :: Mat{spacedim(s), nvertices(s), numtype(s)}
end
vertexmatrix(s::AbstractConvexHull) = Matrix(vertexmat(s))::Matrix{numtype(s)}

Base.convert{S <: Simplex}(::Type{S}, fs::FlexibleSimplex) = S(tuple(vertices(fs)...))
Base.convert{F <: AFG}(::Type{F}, s::Simplex) = F(collect(vertices(s)))
Base.convert{FS <: FlexibleSimplex}(::Type{FS}, f::FS) = f
Base.convert{FG <: AFG, FS <: FlexibleSimplex}(::Type{FG}, f::FS) = FG(vertices(f))
Base.convert{R <: HyperRectangle}(::Type{R}, c::HyperCube) = R(origin(c), widths(c))
Base.convert{F <: FlexibleConvexHull}(::Type{F}, s::Simplex) = F(collect(vertices(c)))
Base.convert{F <: FlexibleConvexHull}(::Type{F}, c) = F(collect(vertices(c)))

function Base.isapprox(s1::AbstractConvexHull, s2::AbstractConvexHull;kw...)
    isapprox(vertexmat(s1), vertexmat(s2); kw...)
end
