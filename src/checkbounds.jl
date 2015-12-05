"""
Check the `Face` indices to ensure they are in the bounds of the vertex
array of the `AbstractMesh`.
"""
function Base.checkbounds{VT,FT,FD,FO}(m::AbstractMesh{VT,Face{FD,FT,FO}})
    isempty(faces(m)) && return true # nothing to worry about I guess

    # index max and min
    const i = one(FO) + FO # normalize face offset
    s = length(vertices(m)) + FO

    for face in faces(m)
        # I hope this is unrolled
        for elt in face
            i <= elt && elt <= s || return false
        end
    end
    return true
end
