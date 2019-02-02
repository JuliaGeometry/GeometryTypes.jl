struct MultiPolygon{T, P<:AbstractPoint}
   polys::Vector{Polygon{T, P}}
   bbox::HyperRectangle{T}
   ishole::Vector{Bool}
end

struct Polygon{T, P<:AbstractPoint}
   points::Vector{P{T}}
   bbox::HyperRectangle{T}
   isconvex::Bool
end

Polygon(points::Vector{P{T}}, bbox::HyperRectangle{T}, isconvex::Bool) where T where P <: AbstractPoint =
    Polygon{T, P}(points, bbox, isconvex)

Polygon(points::AbstractVector{P{T}}) where T where P <: AbstractPoint = Polygon(points, boundingbox(points), isconvex(points))
Polygon(points::AbstractVector) = Polygon(Point.(points))

boundingbox(points::AbstractVector{P{T}}) where T where P <: AbstractPoint = error("implement")
isconvex(points::AbstractVector{P{T}}) where T where P <: AbstractPoint = error("implement")

vertices(poly::P) where P <: Polygon = poly.points

function isinside(r::AbstractPoint, poly::Polygon)
    # An implementation of Hormann-Agathos (2001) Point in Polygon algorithm
    # See: http://www.sciencedirect.com/science/article/pii/S0925772101000128
    # Code segment adapted from PolygonClipping.jl
    isinside(r, poly.bbox) || return false
    c = false
    detq(q1,q2,r) = (q1[1]-r[1])*(q2[2]-r[2])-(q2[1]-r[1])*(q1[2]-r[2])
    for i in eachindex(vertices(poly))[2:end]
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

function isinside(r::AbstractPoint, poly::M) where M <: MultiPolygon)
    isinside(r, poly.bbox) || return false
    for p in findall(poly.ishole)
        isinside(r, poly.polys[p]) && return false
    end
    for p in findall(.!(poly.ishole))
        isinside(r, poly.polys[p]) && return true
    end
    return false
end

isinside(r::AbstractPoint, bbox::HyperRectangle) =
    origin(bbox)[1] < r[1] < widths(bbox)[1] && origin(bbox)[1] < r[2] < widths(bbox)[2]
