using GeometryTypes
# function intersects{N,T}(a::LineSegment{Point{N,T}}, b::LineSegment{Point{N,T}})
#     x12 = a[1][1] - a[2][1]
#     x34 = b[1][1] - b[2][1]
#     y12 = a[1][2] - a[2][2]
#     y34 = b[1][2] - b[2][2]
#
#     c = x12 * y34 - y12 * x34;
#     if abs(c) < 0.01
#         # No intersection
#         return false, Point{2,T}(0,0);
#     else
#         # Intersection
#         ai = a[1][1] * a[2][2] - a[1][2] * a[2][1];
#         bi = b[1][1] * b[2][2] - b[1][2] * b[2][1];
#
#         x = (ai * x34 - bi * x12) / c;
#         y = (ai * y34 - bi * y12) / c;
#
#         return true, Point{2,T}(x,y)
#     end
# end
"""
Intersection of 2 line segmens `a` and `b`.
Returns intersection_found::Bool, intersection_point
"""
function intersects(a::LineSegment{Point{N,T}}, b::LineSegment{Point{N,T}}) where {N,T}
    v1, v2 = a; v3, v4 = b; MT = Mat{2,2,T,4}; p0 = zero(Point{N,T})

    a = det(MT(
        v1[1] - v2[1], v1[2] - v2[2],
        v3[1] - v4[1], v3[2] - v4[2]
    ))
    (abs(a) < eps(T)) && return false, p0 # Lines are parallel

    d1 = det(MT(v1..., v2...))
    d2 = det(MT(v3..., v4...))
    x = det(MT(d1, v1[1] - v2[1], d2, v3[1] - v4[1])) / a;
    y = det(MT(d1, v1[2] - v2[2], d2, v3[2] - v4[2])) / a;

    (x < min(v1[1], v2[1]) - eps(T) || x > max(v1[1], v2[1]) + eps(T)) && return false, p0
    (y < min(v1[2], v2[2]) - eps(T) || y > max(v1[2], v2[2]) + eps(T)) && return false, p0
    (x < min(v3[1], v4[1]) - eps(T) || x > max(v3[1], v4[1]) + eps(T)) && return false, p0
    (y < min(v3[2], v4[2]) - eps(T) || y > max(v3[2], v4[2]) + eps(T)) && return false, p0

    return true, Point{N,T}(x, y)
end


function simple_concat(vec, range, endpoint::P) where P
    result = Vector{P}(length(range)+1)
    for (i,j) in enumerate(range)
        result[i] = vec[mod1(j, length(vec))]
    end
    result[end] = endpoint
    result
end

"""
Finds all self intersections of polygon `points`
"""
function self_intersections(points::Vector{Point{N,T}}) where {N,T}
    sections = Point{N,T}[]
    intersections = Int[]
    wraparound = i-> mod1(i, length(points) - 1)
    for (i, (a,b)) in enumerate(partition(points, 2, 1))
        for (j, (a2, b2)) in enumerate(partition(points, 2, 1))
            is1, is2 = wraparound(i+1), wraparound(i-1)
            if i!=j && is1!=j && is2!=j && !(i in intersections) && !(j in intersections)
                intersected, p = GeometryTypes.intersects(LineSegment(a,b), LineSegment(a2, b2))
                if intersected
                    push!(intersections, i, j)
                    push!(sections, p)
                end
            end
        end
    end
    intersections, sections
end

"""
Splits polygon `points` into it's self intersecting parts. Only 1 intersection
is handled right now.
"""
function split_intersections(points::Vector{Point{N,T}}) where {N,T}
    intersections, sections = self_intersections(points)
    if isempty(intersections)
        return Vector{Point{N,T}}[points]
    elseif length(intersections) == 2 && length(sections) == 1
        a,b = intersections
        p = sections[1]
        a,b = min(a,b), max(a,b)
        poly1 = simple_concat(points, (a+1):(b-1), p)
        poly2 = simple_concat(points, (b+1):(length(points)+a), p)
        return Vector{Point{N,T}}[poly1, poly2]
    else
        error("More than 1 intersections can't be handled currently. Found: $intersections, $sections")
    end
end
