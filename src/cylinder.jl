origin{N,T}(c::Cylinder{N,T}) = c.origin
extremity{N,T}(c::Cylinder{N,T}) = c.extremity
radius{N,T}(c::Cylinder{N,T}) = c.r
height{N,T}(c::Cylinder{N,T}) = norm(c.extremity-c.origin)
direction{N,T}(c::Cylinder{N,T}) = (c.extremity .- c.origin)./height(c)

function rotation{N,T}(c::Cylinder{N,T})
  u = [direction(c)...]
  if N==2
  elseif N==3
    v = abs(u[1])>0 || abs(u[2])>0 ? [u[2],-u[1],0] : [0,-u[3],u[2]]
    v ./= norm(v)
    w = [u[2]*v[3]-u[3]*v[2],-u[1]*v[3]+u[3]*v[1],u[1]*v[2]-u[2]*v[1]]
    return hcat(v,w,u)
  end
end
