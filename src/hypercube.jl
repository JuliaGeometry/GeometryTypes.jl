origin(prim::HyperCube) = prim.origin
widths{N,T}(prim::HyperCube{N,T}) = Vec{N,T}(prim.width)
maximum{N,T}(prim::HyperCube{N,T}) = origin(prim)+widths(prim)
minimum{N,T}(prim::HyperCube{N,T}) = origin(prim)
