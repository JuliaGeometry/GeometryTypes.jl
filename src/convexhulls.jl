Base.eltype(fg::AFG) = eltype(typeof(fg))
Base.length(fg::AFG) = length(vertices(fg))
nvertices(fg::AFG) = length(fg)
nvertices{n, T}(::Type{Simplex{n, T}}) = n
nvertices{N,T}(::Type{HyperCube{N,T}}) = 2^N
nvertices{N,T}(::Type{HyperRectangle{N,T}}) = 2^N
nvertices(s::Union{AbstractGeometry, Simplex}) = nvertices(typeof(s))

spacedim(s) = length(eltype(s))
spacedim{N,T}(::HyperCube{N,T}) = N
numtype(s) = eltype(eltype(s))
numtype{N,T}(::HyperCube{N,T}) = T

Base.push!(fl::AFG, pt) = (push!(vertices(fl), pt); fl)
Base.deleteat!(c::AbstractFlexibleGeometry, i) = (deleteat!(vertices(c), i); c)

Base.copy{FG <: AFG}(fl::FG) = FG(copy(vertices(fl)))
push(fl::AFG, pt) = push!(copy(fl), pt)

vertices(s::Simplex) = s._
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

@generated function standard_cube_vertices{N}(::Type{Val{N}})
    @assert N::Int > 0
    quote
        vert_last = standard_cube_vertices($(Val{N-1}))
        vert_1 = standard_cube_vertices(Val{1})
        _combine_vcat(vert_1, vert_last)
    end
end

@generated function vertices{N,T}(r::HyperRectangle{N,T})
    ret_type = NTuple{(2^N), Vec{N,T}}
    quote
        o = origin(r)
        v = widths(r)
        f(sv) = o + sv .* v
        tuple(map(f, standard_cube_vertices(Val{N}))...)::$ret_type
    end
end

vertices(c::HyperCube) = vertices(convert(HyperRectangle, c))
vertices(s::AbstractConvexHull) = s._

vertexmat(s::Simplex) = Mat(map(Tuple, vertices(s)))
vertexmat(s::AbstractGeometry) = Mat(map(Tuple, vertices(s)))
function vertexmat(s::AbstractFlexibleGeometry)
    tuptup = tuple(map(Tuple, vertices(s))...)
    Mat(tuptup) :: Mat{spacedim(s), nvertices(s), numtype(s)}
end
vertexmatrix(s::AbstractConvexHull) = Matrix(vertexmat(s))::Matrix{numtype(s)}

convert{S <: Simplex}(::Type{S}, fs::FlexibleSimplex) = S(tuple(vertices(fs)...))
convert{F <: AFG}(::Type{F}, s::Simplex) = F(collect(vertices(s)))
convert{FS <: FlexibleSimplex}(::Type{FS}, f::FS) = f
convert{FG <: AFG, FS <: FlexibleSimplex}(::Type{FG}, f::FS) = FG(vertices(f))
convert{R <: HyperRectangle}(::Type{R}, c::HyperCube) = R(origin(c), widths(c))
convert{F <: FlexibleConvexHull}(::Type{F}, s::Simplex) = F(collect(vertices(s)))
convert{F <: FlexibleConvexHull}(::Type{F}, c) = F(collect(vertices(c)))

function Base.isapprox(s1::AbstractConvexHull, s2::AbstractConvexHull;kw...)
    isapprox(vertexmat(s1), vertexmat(s2); kw...)
end
