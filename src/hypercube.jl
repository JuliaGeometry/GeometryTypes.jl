origin(prim::HyperCube) = prim.origin
width(prim::HyperCube)  = prim.width
widths(prim::HyperCube{N,T}) where {N,T} = Vec{N,T}(prim.width)
maximum(prim::HyperCube{N,T}) where {N,T} = origin(prim)+widths(prim)
minimum(prim::HyperCube{N,T}) where {N,T} = origin(prim)
centered(C::Type{HyperCube{N,T}}) where {N,T} = C(Vec{N,T}(-0.5), T(1))
function centered(::Type{T}) where T <: HyperCube
    centered(HyperCube{ndims_or(T, 3), eltype_or(T, Float32)})
end
