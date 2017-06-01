eltype_or(::Type{G}, or) where G <: (AbstractGeometry{N, T} where N) where T = T
eltype_or(::Type{G}, or) where G <: (AbstractGeometry{N, T} where {N, T}) = or

ndims_or(::Type{G}, or) where G <: (AbstractGeometry{N, T} where T) where N = N
ndims_or(::Type{G}, or) where G <: (AbstractGeometry{N, T} where {N, T}) = or


Base.eltype(T::Type{<:AbstractGeometry}) = eltype_or(T, Any)

function Base.ndims(T::Type{<:AbstractGeometry})
    ndims_or(T, Any)
end

Base.eltype{N, T}(x::AbstractGeometry{N, T}) = T
Base.ndims{N, T}(x::AbstractGeometry{N, T}) = N

Base.eltype{T}(::Type{AFG{T}}) = T
Base.eltype{FG <: AFG}(::Type{FG}) = eltype(supertype(FG))
