
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
Base.eltype{FG <: AFG}(::Type{FG}) = eltype(super(FG))
Base.eltype(fg::AFG) = eltype(typeof(fg))
Base.length(fg::AFG) = length(vertices(fg))
nvertices(fg::AFG) = length(fg)
nvertices{n, T}(s::Type{Simplex{n, T}}) = n
nvertices(s::Simplex) = nvertices(typeof(s))
spacedim(s) = length(eltype(s))
numtype(s) = eltype(eltype(s))

Base.push!(fl::AFG, pt) = (push!(vertices(fl), pt); fl)
Base.copy{FG <: AFG}(fl::FG) = FG(copy(vertices(fl)))
push(fl::AFG, pt) = push!(copy(fl), pt)

vertices(s::Simplex) = s._
vertices(s::AbstractConvexHull) = s._

vertexmat(s::Simplex) = Mat(map(Tuple, vertices(s)))
function vertexmat(s::AbstractConvexHull)
    tuptup = tuple(map(Tuple, vertices(s))...)
    Mat(tuptup) :: Mat{spacedim(s), nvertices(s), numtype(s)}
end
vertexmatrix(s::AbstractConvexHull) = Matrix(vertexmat(s))::Matrix{numtype(s)}

Base.convert{S <: Simplex}(::Type{S}, fs::FlexibleSimplex) = S(tuple(vertices(fs)...))
Base.convert{F <: AFG}(::Type{F}, s::Simplex) = F(collect(vertices(s)))
Base.convert{FS <: FlexibleSimplex}(::Type{FS}, f::FS) = f
Base.convert{FG <: AFG, FS <: FlexibleSimplex}(::Type{FG}, f::FS) = FG(vertices(f))

function Base.isapprox(s1::AbstractConvexHull, s2::AbstractConvexHull;kw...)
    isapprox(vertexmat(s1), vertexmat(s2); kw...)
end
