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


