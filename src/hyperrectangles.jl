origin(prim::HyperRectangle) = prim.origin
maximum(prim::HyperRectangle) = origin(prim) + widths(prim)
minimum(prim::HyperRectangle) = origin(prim)
length(prim::HyperRectangle{N, T}) where {T, N} = N
widths(prim::HyperRectangle) = prim.widths

"""
Splits an HyperRectangle into two along an axis at a given location.
"""
split(b::HyperRectangle, axis, value::Integer) = _split(b, axis, value)
split(b::HyperRectangle, axis, value::Number) = _split(b, axis, value)
function _split(b::H, axis, value) where H<:HyperRectangle
    bmin = minimum(b)
    bmax = maximum(b)
    b1max = setindex(bmax, value, axis)
    b2min = setindex(bmin, value, axis)

    return H(bmin, b1max-bmin),
           H(b2min, bmax-b2min)
end

# empty constructor such that update will always include the first point
function (HR::Type{Rect{N, T}})() where {T,N}
    HR(Vec{N,T}(typemax(T)), Vec{N,T}(typemin(T)))
end

# conversion from other HyperRectangles
function (HR::Type{Rect{N,T1}})(a::Rect{N, T2}) where {N,T1,T2}
    HR(Vec{N, T1}(minimum(a)), Vec{N, T1}(widths(a)))
end

function Rect(v1::Vec{N, T1}, v2::Vec{N, T2}) where {N,T1,T2}
    T = promote_type(T1, T2)
    Rect{N,T}(Vec{N, T}(v1), Vec{N, T}(v2))
end


function Rect{N, T}(a::GeometryPrimitive) where {N, T}
    Rect{N, T}(Vec{N, T}(minimum(a)), Vec{N, T}(widths(a)))
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

Rect(r::SimpleRectangle{T}) where T = HyperRectangle{2, T}(r)
Rect{N}(r::SimpleRectangle{T}) where {N, T} = Rect{N, T}(r)

function Rect{N, T}(r::SimpleRectangle) where {N, T}
    if N === 2
        return Rect(Vec{N, T}(T(r.x), T(r.y)), Vec{N, T}(T(r.w), T(r.h)))
    else
        return Rect(
            Vec{N, T}(r.x, r.y, Vec{N - 2}(zero(T))...),
            Vec{N, T}(r.w, r.h, Vec{N - 2}(zero(T))...)
        )
    end
end

#=
From other types
=#
function Rect2D(xy::NamedTuple{(:x, :y)}, wh::NamedTuple{(:width, :height)})
    Rect2D(xy.x, xy.y, wh.width, wh.height)
end


function FRect3D(x::Rect2D{T}) where T
    FRect3D{T}(Vec{3, T}(minimum(x)..., 0), Vec{3, T}(widths(x)..., 0.0))
end

#=
From different args
=#
function Rect2D(x::Number, y::Number, w::Number, h::Number)
    args = promote(x, y, w, h)
    FRect2D{2, eltype(args)}(args...)
end
function Rect2D{T}(args::Vararg{Number, 4}) where T
    x, y, w, h = T <: Integer ? round.(T, args) : args
    FRect2D{T}(Vec{2, T}(x, y), Vec{2, T}(w, h))
end

function Rect2D(xy::VecTypes{2}, w::Number, h::Number)
    Rect2D(xy..., w, h)
end

function Rect2D(x::Number, y::Number, wh::VecTypes{2})
    Rect2D(x, y, wh...)
end

#=
From limits
=#
function FRect3D(x::Tuple{Tuple{<: Number, <: Number}, Tuple{<: Number, <: Number}})
    FRect3D(Vec3f0(x[1]..., 0), Vec3f0(x[2]..., 0))
end
function FRect3D(x::Tuple{Tuple{<: Number, <: Number, <: Number}, Tuple{<: Number, <: Number, <: Number}})
    FRect3D(Vec3f0(x[1]...), Vec3f0(x[2]...))
end


"""
Transform a `HyperRectangle` using a matrix. Maintains axis-align properties
so a significantly larger HyperRectangle may be generated.
"""
function *(m::Mat{N1,N1,T1}, h::HyperRectangle{N2, T2}) where {N1,N2,T1,T2}

    # TypeVar constants
    T = promote_type(T1, T2)
    D = N1 - N2

    # get all points on the HyperRectangle
    d = decompose(Point, h)
    # make sure our points are sized for the tranform
    pts = (Vec{N1, T}[vcat(pt, ones(Vec{D, T})) for pt in d]...,)::NTuple{2^N2,Vec{N1,T}}

    vmin = Vec{N1, T}(typemax(T))
    vmax = Vec{N1, T}(typemin(T))
    # tranform all points, tracking min and max points
    for pt in pts
        pn = m * pt
        vmin = min.(pn, vmin)
        vmax = max.(pn, vmax)
    end
    HyperRectangle{N2, T}(vmin, vmax - vmin)
end


function -(h::HyperRectangle{N, T}, move::Vec{N}) where {N,T}
    HyperRectangle{N, T}(minimum(h) .- move, widths(h))
end
function +(h::HyperRectangle{N, T}, move::Vec{N}) where {N,T}
    HyperRectangle{N, T}(minimum(h) .+ move, widths(h))
end

function -(h::SimpleRectangle{T}, move::Vec{2}) where T
    SimpleRectangle{T}((minimum(h) .- move)..., widths(h)...)
end
function +(h::SimpleRectangle{T}, move::Vec{2}) where T
    SimpleRectangle{T}((minimum(h) .+ move)..., widths(h)...)
end

function *(m::Mat{N,N,T1}, h::HyperRectangle{N,T2}) where {N,T1,T2}
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
        pn = m * Vec(pt)
        vmin = min.(pn, vmin)
        vmax = max.(pn, vmax)
    end
    HyperRectangle{N,T}(vmin, vmax-vmin)
end

# fast path. TODO make other versions fast without code duplications like now
function *(m::Mat{4,4,T}, h::HyperRectangle{3,T}) where T
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
        vmin = min.(pn, vmin)
        vmax = max.(pn, vmax)
    end
    _vmin = Vec{3, T}(vmin[1], vmin[2], vmin[3])
    _vmax = Vec{3, T}(vmax[1], vmax[2], vmax[3])
    HyperRectangle{3,T}(_vmin, _vmax - _vmin)
end

function HyperRectangle(geometry::AbstractArray{<: Point{N, T}}) where {N,T}
    HyperRectangle{N,T}(geometry)
end

@inline function minmax(p::StaticVector, vmin, vmax)
    isnan(p) && return (vmin, vmax)
    min.(p, vmin), max.(p, vmax)
end

# Annoying special case for view(Vector{Point}, Vector{Face})
@inline function minmax(tup::Tuple, vmin, vmax)
    for p in tup
        isnan(p) && continue
        vmin = min.(p, vmin)
        vmax = max.(p, vmax)
    end
    vmin, vmax
end

"""
Construct a HyperRectangle enclosing all points.
"""
function (t::Type{HyperRectangle{N1, T1}})(
        geometry::AbstractArray{PT}
    ) where {N1, T1, PT <: Point}
    N2, T2 = length(PT), eltype(PT)
    @assert N1 >= N2
    vmin = Point{N2, T2}(typemax(T2))
    vmax = Point{N2, T2}(typemin(T2))
    for p in geometry
        vmin, vmax = minmax(p, vmin, vmax)
    end
    o = vmin
    w = vmax - vmin
    if N1 > N2
        z = zero(Vec{N1-N2, T1})
        return HyperRectangle{N1, T1}(vcat(o, z),
                                     vcat(w, z))
    else
        return HyperRectangle{N1, T1}(o, w)
   end
end



xwidth(a::SimpleRectangle)  = a.w + a.x
width(a::SimpleRectangle)  = a.w
yheight(a::SimpleRectangle) = a.h + a.y
height(a::SimpleRectangle) = a.h
area(a::SimpleRectangle) = a.w*a.h
widths(a::SimpleRectangle{T}) where {T} = Point{2,T}(a.w, a.h)
maximum(a::SimpleRectangle{T}) where {T} = Point{2, T}(a.x + widths(a)[1], a.y +widths(a)[2])
minimum(a::SimpleRectangle{T}) where {T} = Point{2, T}(a.x, a.y)
origin(a::SimpleRectangle{T}) where {T} = Point{2, T}(a.x, a.y)

SimpleRectangle(val::Vec{2, T}) where {T} = SimpleRectangle{T}(0, 0, val...)
function SimpleRectangle(position::Vec{2,T}, width::Vec{2,T}) where T
    SimpleRectangle{T}(position..., width...)
end

function Base.to_indices(A::AbstractArray{T, 2}, I::Tuple{<: SimpleRectangle}) where T
    i = I[1]
    (i.x + 1 : (i.x + i.w), i.y + 1 : (i.y + i.h))
end

AbsoluteRectangle(mini::Vec{N,T}, maxi::Vec{N,T}) where {N,T} = HyperRectangle{N,T}(mini, maxi-mini)

AABB(a) = AABB{Float32}(a)

function Rect{T}(a::Pyramid) where T
    w,h = a.width/T(2), a.length
    m = Vec{3,T}(a.middle)
    Rect{T}(m-Vec{3,T}(w,w,0), m+Vec{3,T}(w, w, h))
end

Rect{T}(a::Cube) where T = Rect{T}(origin(a), widths(a))

Rect{T}(a::AbstractMesh) where T = Rect{T}(vertices(a))

function positive_widths(rect::Rect{N, T}) where {N, T}
    mini, maxi = minimum(rect), maximum(rect)
    realmin = min.(mini, maxi)
    realmax = max.(mini, maxi)
    Rect{N, T}(realmin, realmax .- realmin)
end
