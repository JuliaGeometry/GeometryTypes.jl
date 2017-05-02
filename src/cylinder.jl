origin{N,T}(c::Cylinder{N,T}) = c.origin
extremity{N,T}(c::Cylinder{N,T}) = c.extremity
radius{N,T}(c::Cylinder{N,T}) = c.r
height{N,T}(c::Cylinder{N,T}) = norm(c.extremity-c.origin)
direction{N,T}(c::Cylinder{N,T}) = (c.extremity.-c.origin)./height(c)

function rotation{T}(c::Cylinder{2,T})
    d2 = direction(c); u = @SVector [d2[1],d2[2],T(0)]
    v = @SVector [u[2],-u[1],T(0)]
    v = normalize(v)
    return hcat(v,u,@SVector T[0,0,1])
end
function rotation{T}(c::Cylinder{3,T})
    d3 = direction(c); u = @SVector [d3[1],d3[2],d3[3]]
    if (abs(u[1])>0 || abs(u[2])>0)
        v = @SVector [u[2],-u[1],T(0)]
    else
        v = @SVector [T(0),-u[3],u[2]]
    end
    v = normalize(v)
    w = @SVector [u[2]*v[3]-u[3]*v[2],-u[1]*v[3]+u[3]*v[1],u[1]*v[2]-u[2]*v[1]]
    return hcat(v,w,u)
end
