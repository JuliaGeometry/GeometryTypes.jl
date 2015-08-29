#Sums up the normals over all surrounding faces of a single vertex
function normals{VT, FT <: Face}(vertices::Vector{Point{3, VT}}, faces::Vector{FT}, NT = Normal{3, VT})
    normals_result = zeros(Point{3, VT}, length(vertices)) # initilize with same type as verts but with 0
    for face in faces
        v1, v2, v3 = vertices[face]
        a = v2 - v1
        b = v3 - v1
        n = cross(a,b)
        normals_result[face] = normals_result[face] .+ n
    end
    map!(normalize, normals_result)
    map(NT, normals_result)
end



    
call{T}(::Type{AABB{T}}, min_x, min_y, min_z, max_x, max_y, max_z) = AABB(Vec{3, T}(min_x, min_y, min_z), Vec{3, T}(max_x, max_y, max_z))

call{T}(::Type{AABB{T}}, r::Rectangle) = AABB(Vec{3, T}(T(r.x), T(r.y), zero(T)), Vec{3, T}(T(xwidth(r)), T(yheight(r)), zero(T)))
call{T}(::Type{AABB{T}}, aabb::AABB)      = AABB(Vec{3, T}(aabb.min), Vec{3, T}(aabb.max))
call{T}(::Type{AABB}, min::Vec{3, T}, max::Vec{3, T}) = AABB{T}(min, max)


#(*){T}(m::Matrix4x4{T}, bb::AABB{T}) = nothing


function convert{N, T, T2}(::Type{HyperRectangle{N, T}}, geometry::Array{Point{N, T2}}) 
    vmin = Point{N, T2}(typemax(T2))
    vmax = Point{N, T2}(typemin(T2))
    for p in geometry
         vmin = min(p, vmin)
         vmax = max(p, vmax)
    end
    HyperRectangle{N, T}(vmin, vmax)
end
function convert{T, T2}(::Type{HyperRectangle{3, T}}, geometry::Array{Point{2, T2}}) 
    vmin = Point{2, T2}(typemax(T2))
    vmax = Point{2, T2}(typemin(T2))
    @inbounds for i=1:length(geometry)
         vmin = min(geometry[i], vmin)
         vmax = max(geometry[i], vmax)
    end
    HyperRectangle{3, T}(Vec(vmin, T(0)), Vec(vmax, T(0)))
end
xwidth(a::Rectangle)  = a.w + a.x
width(a::Rectangle)  = a.w
yheight(a::Rectangle) = a.h + a.y
height(a::Rectangle) = a.h
area(a::Rectangle) = a.w*a.h
isless(a::Rectangle, b::Rectangle) = isless(area(a), area(b))

call{T}(::Type{Rectangle}, val::Vec{2, T}) = Rectangle{T}(0, 0, val...)

function isinside(rect::Rectangle, x::Real, y::Real)
    rect.x <= x && rect.y <= y && rect.x + rect.w >= x && rect.y + rect.h >= y 
end

function isinside(circle::Circle, x::Real, y::Real)
    xD = abs(circle.x - x) - circle.r 
    yD = abs(circle.y - y) - circle.r
    xD <= 0 && yD <= 0
end



