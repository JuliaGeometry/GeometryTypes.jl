"""
```
normals{VT,FD,FT,FO}(vertices::Vector{Point{3, VT}},
                     faces::Vector{Face{FD,FT,FO}},
                     NT = Normal{3, VT})
```

Compute all vertex normals.
"""
function normals{VT,FD,FT,FO}(vertices::Vector{Point{3, VT}},
                                 faces::Vector{Face{FD,FT,FO}},
                                 NT = Normal{3, VT})
    normals_result = zeros(Point{3, VT}, length(vertices)) # initilize with same type as verts but with 0
    for face in faces
        v = vertices[face]
        # we can get away with two edges since faces are planar.
        a = v[2] - v[1]
        b = v[3] - v[1]
        n = cross(a,b)
        for elt in face
            normals_result[elt-FO] = normals_result[elt-FO] + n
        end
    end
    map!(normalize, normals_result)
    map(NT, normals_result)
end


