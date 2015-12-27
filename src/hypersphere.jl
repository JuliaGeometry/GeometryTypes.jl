call(::Type{Sphere}, x...) = HyperSphere(x...)

call(::Type{Circle}, x...) = HyperSphere(x...)

origin(c::HyperSphere) = c.center
