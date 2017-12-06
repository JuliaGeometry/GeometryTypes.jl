origin(c::Cylinder{N, T}) where {N, T} = c.origin
extremity(c::Cylinder{N, T}) where {N, T} = c.extremity
radius(c::Cylinder{N, T}) where {N, T} = c.r
height(c::Cylinder{N, T}) where {N, T} = norm(c.extremity - c.origin)
direction(c::Cylinder{N, T}) where {N, T} = (c.extremity .- c.origin) ./ height(c)

function rotation(c::Cylinder{2, T}) where T
    d2 = direction(c); u = @SVector [d2[1], d2[2], T(0)]
    v = @MVector [u[2], -u[1], T(0)]
    normalize!(v)
    return hcat(v, u, @SVector T[0, 0, 1])
end
function rotation(c::Cylinder{3, T}) where T
    d3 = direction(c); u = @SVector [d3[1], d3[2], d3[3]]
    if abs(u[1]) > 0 || abs(u[2]) > 0
        v = @MVector [u[2], -u[1], T(0)]
    else
        v = @MVector [T(0), -u[3], u[2]]
    end
    normalize!(v)
    w = @SVector [u[2] * v[3] - u[3] * v[2], -u[1] * v[3] + u[3] * v[1], u[1] * v[2] - u[2] * v[1]]
    return hcat(v, w, u)
end
