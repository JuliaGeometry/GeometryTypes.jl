
origin(c::Cylinder3) = c.origin
extremity(c::Cylinder3) = c.extremity
radius(c::Cylinder3) = c.r
height(c::Cylinder3) = norm(c.extremity-c.origin)
direction(c::Cylinder3) = (c.extremity .- c.origin)./height(c)
function rotation(c::Cylinder3)
  u = [direction(c)...];
  v = abs(u[1])>0 || abs(u[2])>0 ? [u[2],-u[1],0] : [0,-u[3],u[2]]
  v ./= norm(v)
  w = [u[2]*v[3]-u[3]*v[2],-u[1]*v[3]+u[3]*v[1],u[1]*v[2]-u[2]*v[1]]
  return hcat(v,w,u)
end
