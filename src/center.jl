centered(C::Type{HyperCube{N,T}}) where {N,T} = C(Vec{N,T}(-0.5), T(1))
function centered(::Type{T}) where T <: HyperCube
    centered(HyperCube{ndims_or(T, 3), eltype_or(T, Float32)})
end

centered(R::Type{HyperRectangle{N,T}}) where {N, T} = R(Vec{N,T}(-0.5), Vec{N,T}(1))
centered(::Type{T}) where {T <: HyperRectangle} = centered(HyperRectangle{ndims_or(T, 3), eltype_or(T, Float32)})

centered(S::Type{HyperSphere{N, T}}) where {N, T} = S(Vec{N,T}(0), T(0.5))
centered(::Type{T}) where {T <: HyperSphere} = centered(HyperSphere{ndims_or(T, 3), eltype_or(T, Float32)})
