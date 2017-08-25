origin(prim::HyperCube) = prim.origin
widths(prim::HyperCube{N,T}) where {N,T} = Vec{N,T}(prim.width)
maximum(prim::HyperCube{N,T}) where {N,T} = origin(prim)+widths(prim)
minimum(prim::HyperCube{N,T}) where {N,T} = origin(prim)
