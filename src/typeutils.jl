eltype_or{N, T}(::Type{GeometryPrimitive{N, T}}, OR) = T
eltype_or{T}(::Type{GeometryPrimitive{TypeVar(:N), T}}, OR) = T
eltype_or{T<:GeometryPrimitive}(::Type{T}, OR) = OR

ndims_or{N, T}(::Type{GeometryPrimitive{N, T}}, OR) = N
ndims_or{N}(::Type{GeometryPrimitive{N, TypeVar(:T)}}, OR) = N
ndims_or{T<:GeometryPrimitive}(::Type{T}, OR) = OR

