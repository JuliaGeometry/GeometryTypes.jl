#Sums up the normals over all surrounding faces of a single vertex
function normals{VT, FT <: Face}(vertices::Vector{Point3{VT}}, faces::Vector{FT}, NT = Normal3{VT})
    normals_result = zeros(Point3{VT}, length(vertices)) # initilize with same type as verts but with 0
    for face in faces
        v1, v2, v3 = vertices[face]
        a = v2 - v1
        b = v3 - v1
        n = cross(a,b)
        normals_result[face] = normals_result[face] .+ n
    end
    map!(normalize, normals_result)
    convert(NT, normals_result)
end


function maxper(v0::Vector3, v1::Vector3)
    return Vector3(max(v0[1], v1[1]),
            max(v0[2], v1[2]),
            max(v0[3], v1[3]))
end
function minper(v0::Vector3, v1::Vector3)
    return Vector3(min(v0[1], v1[1]),
            min(v0[2], v1[2]),
            min(v0[3], v1[3]))
end

Base.minimum{T, NDIM}(x::Array{Vector3{T},NDIM}) = reduce(minper, x)
Base.maximum{T, NDIM}(x::Array{Vector3{T},NDIM}) = reduce(maxper, x)

    
AABB(min_x, min_y, min_z, max_x, max_y, max_z) = AABB(Vector3(min_x, min_y, min_z), Vector3(max_x, max_y, max_z))
AABB(min_x, min_y, min_z, max_x, max_y, max_z) = AABB(Vector3(min_x, min_y, min_z), Vector3(max_x, max_y, max_z))
call{T}(::Type{AABB{T}}, aabb::AABB) = AABB(Vector3{T}(aabb.min), Vector3{T}(aabb.max))

*{T}(m::Matrix4x4{T}, bb::AABB{T}) = AABB(Vector3{T}(m*Vector4{T}(bb.min..., one(T))), Vector3{T}(m*Vector4{T}(bb.max..., one(T))))


function Base.convert{T}(::Type{AABB}, geometry::Array{Point3{T}}) 
    vmin = Point3(typemax(T))
    vmax = Point3(typemin(T))
    @inbounds for i=1:length(geometry)
         vmin = min(geometry[i], vmin)
         vmax = max(geometry[i], vmax)
    end
    AABB(Vector3{T}(vmin), Vector3{T}(vmax))
end
function Base.convert{T}(::Type{AABB}, geometry::Array{Point2{T}}) 
    vmin = Point2(typemax(T))
    vmax = Point2(typemin(T))
    @inbounds for i=1:length(geometry)
         vmin = min(geometry[i], vmin)
         vmax = max(geometry[i], vmax)
    end
    AABB(Vector3{T}(vmin...,0), Vector3{T}(vmax...,0))
end

area(a::Rectangle)      = a.w*a.h
xwidth(a::Rectangle)    = a.w + a.x
yheight(a::Rectangle)   = a.h + a.y
Base.isless(a::Rectangle, b::Rectangle) = isless(area(a), area(b))
