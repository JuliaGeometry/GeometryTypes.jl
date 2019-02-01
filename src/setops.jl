"""
Perform a union between two HyperRectangles.
"""
function union(h1::HyperRectangle{N, T}, h2::HyperRectangle{N, T}) where {T,N}
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
function intersect(h1::HyperRectangle{N, T}, h2::HyperRectangle{N, T}) where {T,N}
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

function isinside(r::AbstractPoint, poly::AbstractVector{<:AbstractPoint})
    # An implementation of Hormann-Agathos (2001) Point in Polygon algorithm
    # See: http://www.sciencedirect.com/science/article/pii/S0925772101000128
    # Code segment adapted from PolygonClipping.jl
    c = false
    detq(q1,q2,r) = (q1[1]-r[1])*(q2[2]-r[2])-(q2[1]-r[1])*(q1[2]-r[2])
    for i in eachindex(poly)[2:end]
        q2 = poly[i]
        q1 = poly[i-1]
        if q1 == r
            @warn("point on polygon vertex - returning false")
            return false
        end
        if q2[2] == r[2]
            if q2[1] == r[1]
                @warn("point on polygon vertex - returning false")
                return false
            elseif (q1[2] == r[2]) && ((q2[1] > x) == (q1[1] < r[1]))
                @warn("point on edge - returning false")
                return false
            end
        end
        if (q1[2] < r[2]) != (q2[2] < r[2]) # crossing
            if q1[1] >= r[1]
                if q2[1] > r[1]
                    c = !c
                elseif ((detq(q1,q2,r) > 0) == (q2[2] > q1[2])) # right crossing
                    c = !c
                end
            elseif q2[1] > r[1]
                if ((detq(q1,q2,r) > 0) == (q2[2] > q1[2])) # right crossing
                    c = !c
                end
            end
        end
    end
    return c
end
