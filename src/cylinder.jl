origin(c::Cylinder{N,T}) where {N,T} = c.origin
extremity(c::Cylinder{N,T}) where {N,T} = c.extremity
radius(c::Cylinder{N,T}) where {N,T} = c.r
height(c::Cylinder{N,T}) where {N,T} = norm(c.extremity-c.origin)
direction(c::Cylinder{N,T}) where {N,T} = (c.extremity.-c.origin)./height(c)

function rotation(c::Cylinder{2,T}) where T
    u = [direction(c)...,0]; v = [u[2],-u[1],0]
    v ./= norm(v)
    return hcat(v,u,[0,0,1])
end
function rotation(c::Cylinder{3,T}) where T
    u = [direction(c)...]
    v = abs(u[1])>0 || abs(u[2])>0 ? [u[2],-u[1],0] : [0,-u[3],u[2]]
    v ./= norm(v)
    w = [u[2]*v[3]-u[3]*v[2],-u[1]*v[3]+u[3]*v[1],u[1]*v[2]-u[2]*v[1]]
    return hcat(v,w,u)
end
