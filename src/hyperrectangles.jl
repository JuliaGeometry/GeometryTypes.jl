maximum(b::HyperRectangle) = b.maximum
minimum(b::HyperRectangle) = b.minimum
length{T, N}(b::HyperRectangle{N, T}) = N
width(b::HyperRectangle) = maximum(b) - minimum(b)

"""
Splits an HyperRectangle into two along an axis at a given location.
"""
split{H<:HyperRectangle}(b::H, axis, value::Integer) = _split(b,axis,value)
split{H<:HyperRectangle}(b::H, axis, value::Number) = _split(b,axis,value)
function _split{H<:HyperRectangle}(b::H, axis, value)
    b1max = setindex(b.maximum, value, axis)
    b2min = setindex(b.minimum, value, axis)

    return H(b.minimum, b1max),
           H(b2min, b.maximum)
end

call{T,N}(::Type{HyperRectangle{N,T}}) =
    HyperRectangle{N, T}(Vec{N,T}(typemin(T)), Vec{N,T}(typemax(T)))

function call{N,T1,T2}(::Type{HyperRectangle{N,T1}}, a::HyperRectangle{N,T2})
    HyperRectangle{N,T1}(Vec{N, T1}(a.minimum), Vec{N, T1}(a.maximum))
end

"""
```
HyperRectangle(vals::Number...)
```
HyperRectangle constructor for indidually specified intervals.
e.g. HyperRectangle(0,0,1,2) has minimum == Vec(0,0) and
maximum == Vec(1,2)
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

call{A<:AABB}(::Type{A}, vals::Number...) = HyperRectangle(vals...)

function HyperRectangle{T}(r::SimpleRectangle{T})
    HyperRectangle{2,T}(r)
end

function call{N,T}(::Type{HyperRectangle{N,T}}, r::SimpleRectangle)
    if N > 2
        return HyperRectangle(Vec{N, T}(T(r.x), T(r.y), [zero(T) for i=1:N-2]...),
                              Vec{N, T}(T(xwidth(r)), T(yheight(r)), [zero(T) for i=1:N-2]...))
    else
        return HyperRectangle(Vec{N, T}(T(r.x), T(r.y)),
                              Vec{N, T}(T(xwidth(r)), T(yheight(r))))
    end
end

# TODO fix
function *{T}(m::Mat{4,4,T}, bb::HyperRectangle{T})
    AABB{Float32}(Vec{3, T}(m*Vec(bb.minimum, one(T))), Vec{3, T}(m*Vec(bb.maximum, one(T))))
end

function HyperRectangle{N,T}(geometry::Array{Point{N, T}})
    HyperRectangle{N,T}(geometry)
end

"""
Construct a HyperRectangle enclosing all points.
"""
function call{N1, N2, T1, T2}(t::Type{HyperRectangle{N1, T1}}, geometry::Array{Point{N2, T2}})
    @assert N1 >= N2
    vmin = Point{N2, T2}(typemax(T2))
    vmax = Point{N2, T2}(typemin(T2))
    for p in geometry
         vmin = min(p, vmin)
         vmax = max(p, vmax)
    end
    if N1 > N2
        return HyperRectangle{N1,T1}(Vec{N1,T1}(vmin..., [zero(T1) for i = 1:N1-N2]...),
                                     Vec{N1,T1}(vmax..., [zero(T1) for i = 1:N1-N2]...))
    else
        return HyperRectangle{N1,T1}(Vec{N1,T1}(vmin),
                                     Vec{N1,T1}(vmax))
   end
end

xwidth(a::SimpleRectangle)  = a.w + a.x
width(a::SimpleRectangle)  = a.w
yheight(a::SimpleRectangle) = a.h + a.y
height(a::SimpleRectangle) = a.h
area(a::SimpleRectangle) = a.w*a.h
maximum{T}(a::SimpleRectangle{T}) = Point{2, T}(xwidth(a), yheight(a))
minimum{T}(a::SimpleRectangle{T}) = Point{2, T}(a.x, a.y)

call{T}(::Type{SimpleRectangle}, val::Vec{2, T}) = SimpleRectangle{T}(0, 0, val...)

