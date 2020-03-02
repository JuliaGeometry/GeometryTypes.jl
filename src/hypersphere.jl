Sphere(x...) = HyperSphere(x...)

Circle(x...) = HyperSphere(x...)

widths(c::HyperSphere{N, T}) where {N, T} = Vec{N, T}(radius(c)*2)
radius(c::HyperSphere) = c.r
origin(c::HyperSphere) = c.center
minimum(c::HyperSphere{N, T}) where {N, T} = Vec{N, T}(origin(c)) - Vec{N, T}(radius(c))
maximum(c::HyperSphere{N, T}) where {N, T} = Vec{N, T}(origin(c)) + Vec{N, T}(radius(c))
function isinside(c::Circle, x::Real, y::Real)
    @inbounds ox, oy = origin(c)
    xD = abs(ox - x)
    yD = abs(oy - y)
    xD <= c.r && yD <= c.r
end

centered(S::Type{HyperSphere{N, T}}) where {N, T} = S(Vec{N,T}(0), T(0.5))
centered(::Type{T}) where {T <: HyperSphere} = centered(HyperSphere{ndims_or(T, 3), eltype_or(T, Float32)})
