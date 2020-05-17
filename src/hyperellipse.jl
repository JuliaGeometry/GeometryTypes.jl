Ellipsoid(x...) = HyperEllipse(x...)

Ellipse(x...) = HyperEllipse(x...)

widths(c::HyperEllipse{N, T}) where {N, T} = Vec{N, T}(radius(c)*2)
radius(c::HyperEllipse) = c.r
origin(c::HyperEllipse) = c.center
minimum(c::HyperEllipse{N, T}) where {N, T} = Vec{N, T}(origin(c)) - radius(c)
maximum(c::HyperEllipse{N, T}) where {N, T} = Vec{N, T}(origin(c)) + radius(c)

_ellipseterm(p, c, r) = ((p - c)/r)^2
isinside(c::HyperEllipse{N,T}, p::Point{N,R}) where {N, T, R} = mapreduce(_ellipseterm, +, p, origin(c), radius(c)) ≤ 1
isinside(c::Ellipse, x::Real, y::Real) = isinside(c, Point(x, y))

centered(S::Type{HyperEllipse{N, T}}) where {N, T} = S(Vec{N,T}(0), Vec{N,T}(0.5))
centered(::Type{T}) where {T <: HyperEllipse} = centered(HyperEllipse{ndims_or(T, 3), eltype_or(T, Float32)})
