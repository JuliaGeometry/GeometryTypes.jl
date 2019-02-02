function Polygon(
        points::AbstractVector;
        boundingbox = Rect2D(points),
        isconvex = isconvex(points),
        ishole = false
    )
    ps = convert(AbstractVector{Point}, points)
    NumType = eltype(eltype(ps))
    Polygon{NumType, typeof(ps)}(ps, boundingbox, isconvex, ishole)
end

iterate(polygons::MultiPolygon) = iterate(polygons.polygons)
iterate(polygons::MultiPolygon, state) = iterate(polygons.polygons, state)

vertices(poly::Polygon) = poly.points
boundingbox(poly::Polygon) = poly.boundingbox
ishole(poly::Polygon) = poly.ishole
isconvex(poly::Polygon) = poly.isconvex


"""
    in(point::AbstractPoint, poly::Polygon)

# An implementation of Hormann-Agathos (2001) Point in Polygon algorithm
# See: http://www.sciencedirect.com/science/article/pii/S0925772101000128
# Code segment adapted from PolygonClipping.jl
"""
function in(point::AbstractPoint, poly::Polygon)
    (point in boundingbox(poly)) || return false
    c = false
    detq(q1, q2, point) = (q1[1]-point[1])*(q2[2]-point[2])-(q2[1]-point[1])*(q1[2]-point[2])
    for (q1, q2) in Partition{2}(poly)
        if q1 == point
            @warn("point on polygon vertex - returning false")
            return false
        end
        if q2[2] == point[2]
            if q2[1] == point[1]
                @warn("point on polygon vertex - returning false")
                return false
            elseif (q1[2] == point[2]) && ((q2[1] > x) == (q1[1] < point[1]))
                @warn("point on edge - returning false")
                return false
            end
        end
        if (q1[2] < point[2]) != (q2[2] < point[2]) # crossing
            if q1[1] >= point[1]
                if q2[1] > point[1]
                    c = !c
                elseif ((detq(q1,q2,point) > 0) == (q2[2] > q1[2])) # right crossing
                    c = !c
                end
            elseif q2[1] > point[1]
                if ((detq(q1,q2,point) > 0) == (q2[2] > q1[2])) # right crossing
                    c = !c
                end
            end
        end
    end
    return c
end

function in(point::AbstractPoint, polygons::MultiPolygon)
    point in boundingbox(polygons) || return false
    for polygon in polygons
        if ishole(polygon)
            point in polygon && return false
        else
            point in polygon && return true
        end
    end
    return false
end

function isconvex(points::AbstractVector{<: AbstractPoint})
    length(points) < 4 && return true
    sign = false
    for (i, (a, b, c)) in enumerate(Partition{3}(points, true))
        Δ1 = c .- b
        Δ2 = a .- b
        det = cross(Δ1, Δ2)
        if i == 1
            sign = det > 0
        elseif (sign != (det > 0))
            return false
        end
    end
    return true
end
