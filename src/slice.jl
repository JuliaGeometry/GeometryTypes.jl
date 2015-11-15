"""
Slice an AbstractMesh at the specified Z axis value.
Returns a Vector of LineSegments generated from the faces at the specified
heights. Note: This will not slice in-plane faces.
"""
function Base.slice{VT<:AbstractFloat,FT<:Integer,O}(mesh::AbstractMesh{Point{3,VT},Face{3,FT,O}}, height::Number)

    height_ct = length(height)
    # intialize the LineSegment array
    slice = Simplex{2,Point{2,VT}}[]

    for face in mesh.faces
        v1 = mesh.vertices[face[1]+O]
        v2 = mesh.vertices[face[2]+O]
        v3 = mesh.vertices[face[3]+O]
        zmax = max(v1[3], v2[3], v3[3])
        zmin = min(v1[3], v2[3], v3[3])
        if height > zmax
            continue
        elseif zmin <= height
            if v1[3] < height && v2[3] >= height && v3[3] >= height
                p1 = v1
                p2 = v3
                p3 = v2
            elseif v1[3] > height && v2[3] < height && v3[3] < height
                p1 = v1
                p2 = v2
                p3 = v3
            elseif v2[3] < height && v1[3] >= height && v3[3] >= height
                p1 = v2
                p2 = v1
                p3 = v3
            elseif v2[3] > height && v1[3] < height && v3[3] < height
                p1 = v2
                p2 = v3
                p3 = v1
            elseif v3[3] < height && v2[3] >= height && v1[3] >= height
                p1 = v3
                p2 = v2
                p3 = v1
            elseif v3[3] > height && v2[3] < height && v1[3] < height
                p1 = v3
                p2 = v1
                p3 = v2
            else
                continue
            end

            start = Point{2,VT}(p1[1] + (p2[1] - p1[1]) * (height - p1[3]) / (p2[3] - p1[3]),
                                p1[2] + (p2[2] - p1[2]) * (height - p1[3]) / (p2[3] - p1[3]))
            finish = Point{2,VT}(p1[1] + (p3[1] - p1[1]) * (height - p1[3]) / (p3[3] - p1[3]),
                                 p1[2] + (p3[2] - p1[2]) * (height - p1[3]) / (p3[3] - p1[3]))

            push!(slice, Simplex{2,Point{2,VT}}(start, finish))
        end
    end

    return slice
end
