"""
```
normals{VT,FD,FT,FO}(vertices::Vector{Point{3, VT}},
                     faces::Vector{Face{FD,FT,FO}},
                     NT = Normal{3, VT})
```

Compute all vertex normals.
"""
function normals(
        vertices::AbstractVector{Point{3, VT}},
        faces::AbstractVector{F},
        NT = Normal{3, VT}
    ) where {VT, F <: Face}
    normals_result = zeros(Point{3, VT}, length(vertices)) # initilize with same type as verts but with 0
    for face in faces
        v = vertices[face]
        # we can get away with two edges since faces are planar.
        a = v[2] - v[1]
        b = v[3] - v[1]
        n = cross(a,b)
        for i =1:length(F)
            fi = face[i]
            normals_result[fi] = normals_result[fi] + n
        end
    end
    normals_result .= NT.(normalize.(normals_result))
    normals_result
end


"""
Slice an AbstractMesh at the specified Z axis value.
Returns a Vector of LineSegments generated from the faces at the specified
heights. Note: This will not slice in-plane faces.
"""
function slice(mesh::AbstractMesh{Point{3,VT}, Face{3, FT}}, height::Number) where {VT<:AbstractFloat,FT<:Integer}

    height_ct = length(height)
    # intialize the LineSegment array
    slice = Simplex{2,Point{2,VT}}[]

    for face in mesh.faces
        v1,v2,v3 = mesh.vertices[face]
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

            push!(slice, Simplex{2,Point{2, VT}}(start, finish))
        end
    end

    return slice
end


# TODO this should be checkbounds(Bool, ...)
"""
```
checkbounds{VT,FT,FD,FO}(m::AbstractMesh{VT,Face{FD,FT,FO}})
```

Check the `Face` indices to ensure they are in the bounds of the vertex
array of the `AbstractMesh`.
"""
function Base.checkbounds(m::AbstractMesh{VT, Face{FD, FT}}) where {VT, FD, FT}
    isempty(faces(m)) && return true # nothing to worry about I guess
    flat_inds = reinterpret(FT, faces(m))
    checkbounds(Bool, vertices(m), flat_inds)
end
