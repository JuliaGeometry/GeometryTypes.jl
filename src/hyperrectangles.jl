origin(prim::HyperRectangle) = prim.origin
maximum(prim::HyperRectangle) = origin(prim) + widths(prim)
minimum(prim::HyperRectangle) = origin(prim)
length{T, N}(prim::HyperRectangle{N, T}) = N
widths(prim::HyperRectangle) = prim.widths

"""
Splits an HyperRectangle into two along an axis at a given location.
"""
split{H<:HyperRectangle}(b::H, axis, value::Integer) = _split(b,axis,value)
split{H<:HyperRectangle}(b::H, axis, value::Number) = _split(b,axis,value)
function _split{H<:HyperRectangle}(b::H, axis, value)
    bmin = minimum(b)
    bmax = maximum(b)
    b1max = setindex(bmax, value, axis)
    b2min = setindex(bmin, value, axis)

    return H(bmin, b1max-bmin),
           H(b2min, bmax-b2min)
end

# empty constructor such that update will always include the first point
function (HR::Type{HyperRectangle{N,T}}){T,N}()
    HR(Vec{N,T}(typemax(T)), Vec{N,T}(typemin(T)))
end

# conversion from other HyperRectangles
function (HR::Type{HyperRectangle{N,T1}}){N,T1,T2}(a::HyperRectangle{N,T2})
    HR(Vec{N, T1}(minimum(a)), Vec{N, T1}(widths(a)))
end

function HyperRectangle{N,T1,T2}(v1::Vec{N,T1}, v2::Vec{N,T2})
    T = promote_type(T1,T2)
    HyperRectangle{N,T}(Vec{N,T}(v1), Vec{N,T}(v2))
end


function (HR::Type{HyperRectangle{N,T}}){N,T}(a::GeometryPrimitive)
    HR(Vec{N, T}(minimum(a)), Vec{N, T}(widths(a)))
end
"""
```
HyperRectangle(vals::Number...)
```
HyperRectangle constructor for indidually specified intervals.
e.g. HyperRectangle(0,0,1,2) has origin == Vec(0,0) and
width == Vec(1,2)
"""
@generated function HyperRectangle(vals::Number...)
    # Generated so we get goodish codegen on each signature
    n = length(vals)
    @assert iseven(n)
    mid = div(n,2)
    v1 = Expr(:call, :Vec)
    v2 = Expr(:call, :Vec)
    # TODO this can be inbounds
    append!(v1.args, [:(vals[$i]) for i = 1:mid])
    append!(v2.args, [:(vals[$i]) for i = mid+1:length(vals)])
    Expr(:call, :HyperRectangle, v1, v2)
end

function HyperRectangle{T}(r::SimpleRectangle{T})
    HyperRectangle{2,T}(r)
end

function (::Type{HyperRectangle{N,T}}){N,T}(r::SimpleRectangle)
    if N > 2
        return HyperRectangle(Vec{N, T}(T(r.x), T(r.y), Vec{N-2,T}(zero(T))...),
                              Vec{N, T}(T(r.w), T(r.h), Vec{N-2,T}(zero(T))...))
    else
        return HyperRectangle(Vec{N, T}(T(r.x), T(r.y)),
                              Vec{N, T}(T(r.w), T(r.h)))
    end
end

"""
Transform a `HyperRectangle` using a matrix. Maintains axis-align properties
so a significantly larger HyperRectangle may be generated.
"""
function *{N1,N2,T1,T2}(m::Mat{N1,N1,T1}, h::HyperRectangle{N2,T2})

    # TypeVar constants
    T = promote_type(T1,T2)
    D = N1 - N2

    # get all points on the HyperRectangle
    d   = decompose(Point, h)
    pts = (Vec{N1,T}[Vec{N1,T}(pt, Vec{D,T}(one(T))...) for pt in d]...)::NTuple{2^N2,Vec{N1,T}}

    # make sure our points are sized for the tranform
    vmin = Vec{N1, T}(typemax(T))
    vmax = Vec{N1, T}(typemin(T))

    # tranform all points, tracking min and max points
    for pt in pts
        pn = m*pt
        vmin = min(pn,vmin)
        vmax = max(pn,vmax)
    end
    HyperRectangle{N2,T}(Vec{N2,T}(vmin), Vec{N2,T}(vmax-vmin))
end

function *{N,T1,T2}(m::Mat{N,N,T1}, h::HyperRectangle{N,T2})
    # equal dimension case

    # TypeVar constants
    T = promote_type(T1,T2)

    # get all points on the HyperRectangle
    pts = decompose(Point, h)

    # make sure our points are sized for the tranform
    vmin = Vec{N, T}(typemax(T))
    vmax = Vec{N, T}(typemin(T))

    # tranform all points, tracking min and max points
    for pt in pts
        pn = m*Vec(pt)
        vmin = min(pn,vmin)
        vmax = max(pn,vmax)
    end
    HyperRectangle{N,T}(vmin, vmax-vmin)
end

# fast path. TODO make other versions fast without code duplications like now
function *{T}(m::Mat{4,4,T}, h::HyperRectangle{3,T})
    # equal dimension case

    # get all points on the HyperRectangle
    pts = (
        Vec{4,T}(0.0,0.0,0.0, 1.0),
        Vec{4,T}(1.0,0.0,0.0, 1.0),
        Vec{4,T}(0.0,1.0,0.0, 1.0),
        Vec{4,T}(1.0,1.0,0.0, 1.0),
        Vec{4,T}(0.0,0.0,1.0, 1.0),
        Vec{4,T}(1.0,0.0,1.0, 1.0),
        Vec{4,T}(0.0,1.0,1.0, 1.0),
        Vec{4,T}(1.0,1.0,1.0, 1.0)
    )

    # make sure our points are sized for the tranform
    vmin = Vec{4, T}(typemax(T))
    vmax = Vec{4, T}(typemin(T))
    o, w = origin(h), widths(h)
    _o = Vec{4, T}(o[1], o[2], o[3], T(0))
    _w = Vec{4, T}(w[1], w[2], w[3], T(1))
    # tranform all points, tracking min and max points
    for pt in pts
        pn = m * (_o + (pt .* _w))
        vmin = min(pn, vmin)
        vmax = max(pn, vmax)
    end
    _vmin = Vec{3,T}(vmin[1], vmin[2], vmin[3])
    _vmax = Vec{3,T}(vmax[1], vmax[2], vmax[3])
    HyperRectangle{3,T}(_vmin, _vmax-_vmin)
end

function HyperRectangle{N,T}(geometry::Array{Point{N, T}})
    HyperRectangle{N,T}(geometry)
end

"""
Construct a HyperRectangle enclosing all points.
"""
function (t::Type{HyperRectangle{N1, T1}}){N1, T1, PT<:Point}(
        geometry::AbstractArray{PT}
    )
    N2, T2 = length(PT), eltype(PT)
    @assert N1 >= N2
    vmin = Point{N2, T2}(typemax(T2))
    vmax = Point{N2, T2}(typemin(T2))
    for p in geometry
         vmin = min(p, vmin)
         vmax = max(p, vmax)
    end
    o = vmin
    w = vmax - vmin
    if N1 > N2
        z = Vec{N1-N2,T1}(zero(T1))
        return HyperRectangle{N1,T1}(Vec{N1,T1}(o, z...),
                                     Vec{N1,T1}(w, z...))
    else
        return HyperRectangle{N1,T1}(Vec{N1,T1}(o),
                                     Vec{N1,T1}(w))
   end
end

xwidth(a::SimpleRectangle)  = a.w + a.x
width(a::SimpleRectangle)  = a.w
yheight(a::SimpleRectangle) = a.h + a.y
height(a::SimpleRectangle) = a.h
area(a::SimpleRectangle) = a.w*a.h
widths{T}(a::SimpleRectangle{T}) = Point{2,T}(a.w, a.h)
maximum{T}(a::SimpleRectangle{T}) = Point{2, T}(a.x + widths(a)[1], a.y +widths(a)[2])
minimum{T}(a::SimpleRectangle{T}) = Point{2, T}(a.x, a.y)
origin{T}(a::SimpleRectangle{T}) = Point{2, T}(a.x, a.y)

(::Type{SimpleRectangle}){T}(val::Vec{2, T}) = SimpleRectangle{T}(0, 0, val...)
function SimpleRectangle{T}(position::Vec{2,T}, width::Vec{2,T})
    SimpleRectangle{T}(position..., width...)
end

function getindex{T}(a::Array{T,2}, rect::SimpleRectangle)
    a[rect.x+1:(rect.x+rect.w), rect.y+1:(rect.y+rect.h)]
end

function setindex!{T}(a::Array{T,2}, b::Array{T,2}, rect::SimpleRectangle)
    a[rect.x+1:rect.w, rect.y+1:rect.h] = b
end
