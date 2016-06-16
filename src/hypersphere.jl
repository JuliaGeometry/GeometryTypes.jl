@compat (::Type{Sphere})(x...) = HyperSphere(x...)

@compat (::Type{Circle})(x...) = HyperSphere(x...)

widths{N, T}(c::HyperSphere{N, T}) = Vec{N, T}(radius(c)*2)
radius(c::HyperSphere) = c.r
origin(c::HyperSphere) = c.center
minimum{N, T}(c::HyperSphere{N, T}) = Vec{N, T}(origin(c)) - Vec{N, T}(radius(c))
maximum{N, T}(c::HyperSphere{N, T}) = Vec{N, T}(origin(c)) + Vec{N, T}(radius(c))
