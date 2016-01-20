centered{N,T}(C::Type{HyperCube{N,T}}) = C(Vec{N,T}(-0.5), T(1))
centered{T<:HyperCube}(::Type{T}) = centered(HyperCube{ndims_or(T, 3), eltype_or(T, Float32)})

centered{N,T}(R::Type{HyperRectangle{N,T}}) = R(Vec{N,T}(-0.5), Vec{N,T}(1))
centered{T<:HyperRectangle}(::Type{T}) = centered(HyperRectangle{ndims_or(T, 3), eltype_or(T, Float32)})

centered{N,T}(S::Type{HyperSphere{N,T}}) = S(Vec{N,T}(0), T(1))
centered{T<:HyperSphere}(::Type{T}) = centered(HyperSphere{ndims_or(T, 3), eltype_or(T, Float32)})
