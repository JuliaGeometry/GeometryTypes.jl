"""
Perform a union between two HyperRectangles.
"""
union{T,N}(h1::HyperRectangle{N, T}, h2::HyperRectangle{N, T}) =
    HyperRectangle{N, T}(min(minimum(h1), minimum(h2)), max(maximum(h1), maximum(h2)))

"""
Perform a difference between two HyperRectangles.
"""
diff(h1::HyperRectangle, h2::HyperRectangle) = h1


"""
Perform a intersection between two HyperRectangles.
"""
intersect{T,N}(h1::HyperRectangle{N, T}, h2::HyperRectangle{N, T}) =
    HyperRectangle{N, T}(max(minimum(h1), minimum(h2)),  min(maximum(h1), maximum(h2)))

function intersect{T}(a::SimpleRectangle{T}, b::SimpleRectangle{T})
    axrange = a.x:xwidth(a)
    ayrange = a.y:yheight(a)

    bxrange = b.x:xwidth(b)
    byrange = b.y:yheight(b)

    xintersect = intersect(axrange, bxrange)
    yintersect = intersect(ayrange, byrange)
    (isempty(xintersect) || isempty(yintersect) ) && return SimpleRectangle(zero(T), zero(T), zero(T), zero(T))
    x,y   = first(xintersect), first(yintersect)
    xw,yh = last(xintersect), last(yintersect)
    SimpleRectangle(x,y, xw-x, yh-y)
end

