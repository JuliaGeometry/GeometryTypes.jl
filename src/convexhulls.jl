Base.eltype(fg::AFG) = eltype(typeof(fg))
Base.length(fg::AFG) = length(vertices(fg))
nvertices(fg::AFG) = length(fg)
nvertices(::Type{Simplex{n, T}}) where {n, T} = n
nvertices(::Type{HyperCube{N,T}}) where {N,T} = 2^N
nvertices(::Type{HyperRectangle{N,T}}) where {N,T} = 2^N
nvertices(s::Union{AbstractGeometry, Simplex}) = nvertices(typeof(s))

spacedim(s) = length(eltype(s))
spacedim(::HyperCube{N,T}) where {N,T} = N
numtype(s) = eltype(eltype(s))
numtype(::HyperCube{N,T}) where {N,T} = T

Base.push!(fl::AFG, pt) = (push!(vertices(fl), pt); fl)
Base.deleteat!(c::AbstractFlexibleGeometry, i) = (deleteat!(vertices(c), i); c)

Base.copy(fl::FG) where {FG <: AFG} = FG(copy(vertices(fl)))
push(fl::AFG, pt) = push!(copy(fl), pt)

vertices(x::AbstractFlexibleGeometry) = x.vertices
vertices(s::Simplex) = Tuple(s)

standard_cube_vertices(::Type{Val{1}}) = [Vec(0), Vec(1)]
_vcat(v1,v2) = Vec(Tuple(v1)..., Tuple(v2)...)
function _combine_vcat(arr1, arr2)
    T = typeof(_vcat(first(arr1), first(arr2)))
    ret = T[]
    for v in arr1, w in arr2
        push!(ret, _vcat(v,w))
    end
    ret
end

@generated function standard_cube_vertices(::Type{Val{N}}) where N
    @assert N::Int > 0
    quote
        vert_last = standard_cube_vertices($(Val{N-1}))
        vert_1 = standard_cube_vertices(Val{1})
        _combine_vcat(vert_1, vert_last)
    end
end
@generated function vertices_rettype(r::HyperRectangle)
    N = ndims(r)
    T = eltype(r)
    RET = NTuple{(2^N), Vec{N,T}}
    :($RET)
end

function vertices(r::HyperRectangle)
    N = ndims(r)
    ret_type = vertices_rettype(r)
    o = origin(r)
    v = widths(r)
    f(sv) = o + sv .* v
    tuple(map(f, standard_cube_vertices(Val{N}))...)::ret_type
end

vertices(c::HyperCube) = vertices(convert(HyperRectangle, c))

vertexmat(s) = hcat(vertices(s)...)
vertexmatrix(s::AbstractConvexHull) = Matrix(vertexmat(s))::Matrix{numtype(s)}

convert(S::Type{<: Simplex}, fs::FlexibleSimplex) = S(tuple(vertices(fs)...))
convert(F::Type{<: AFG}, s::Simplex) = F(collect(vertices(s)))
convert(FG::Type{<: AFG}, f::FlexibleSimplex) = FG(vertices(f))
convert(R::Type{<: HyperRectangle}, c::HyperCube) = R(origin(c), widths(c))
convert(F::Type{<:FlexibleConvexHull}, s::Simplex) = F(collect(vertices(s)))
convert(F::Type{<:FlexibleConvexHull}, s::FlexibleSimplex) = F(vertices(s))
convert(F::Type{FlexibleConvexHull}, c::FlexibleConvexHull) = c
convert(F::Type{<:FlexibleConvexHull}, c::FlexibleConvexHull) = F(vertices(c))
convert(::Type{F}, x::F) where {F <: FlexibleConvexHull} = x
convert(F::Type{<:FlexibleConvexHull}, c) = F(collect(vertices(c)))

function Base.isapprox(s1::AbstractConvexHull, s2::AbstractConvexHull;kw...)
    isapprox(vertexmat(s1), vertexmat(s2); kw...)
end
