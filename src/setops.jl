"""
Perform a union between two HyperRectangles.
"""
function union{T,N}(h1::HyperRectangle{N, T}, h2::HyperRectangle{N, T})
    m = min.(minimum(h1), minimum(h2))
    mm = max.(maximum(h1), maximum(h2))
    HyperRectangle{N, T}(m, mm-m)
end


"""
Perform a difference between two HyperRectangles.
"""
diff(h1::HyperRectangle, h2::HyperRectangle) = h1


"""
Perform a intersection between two HyperRectangles.
"""
function intersect{T,N}(h1::HyperRectangle{N, T}, h2::HyperRectangle{N, T})
    m = max.(minimum(h1), minimum(h2))
    mm = min.(maximum(h1), maximum(h2))
    HyperRectangle{N, T}(m, mm-m)
end

function intersect(a::SimpleRectangle, b::SimpleRectangle)
    min_n = max.(minimum(a), minimum(b))
    max_n = min.(maximum(a), maximum(b))
    w = max_n - min_n
    SimpleRectangle(min_n[1], min_n[2], w[1], w[2])
end
