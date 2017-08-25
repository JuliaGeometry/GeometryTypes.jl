eltype_or(::Type{G}, or) where G <: (AbstractGeometry{N, T} where N) where T = T
eltype_or(::Type{G}, or) where G <: (AbstractGeometry{N, T} where {N, T}) = or

ndims_or(::Type{G}, or) where G <: (AbstractGeometry{N, T} where T) where N = N
ndims_or(::Type{G}, or) where G <: (AbstractGeometry{N, T} where {N, T}) = or


Base.eltype(T::Type{<:AbstractGeometry}) = eltype_or(T, Any)

function Base.ndims(T::Type{<:AbstractGeometry})
    ndims_or(T, Any)
end

Base.eltype(x::AbstractGeometry{N, T}) where {N, T} = T
Base.ndims(x::AbstractGeometry{N, T}) where {N, T} = N

Base.eltype(::Type{AFG{T}}) where {T} = T
Base.eltype(::Type{FG}) where {FG <: AFG} = eltype(supertype(FG))
