"""
Compute the angle between two vectors
"""
function angle(a,b)
    acos(dot(a,b)/sqrt(dot(a,a))*sqrt(dot(b,b)))
end

"""
Compute the angle at element `i` of the `Simplex`.
"""
function angle(s::Simplex{3}, i)
    if i == 1
        v1 = s[2] - s[i]
        v2 = s[3] - s[i]
    elseif i == 2
        v1 = s[3] - s[i]
        v2 = s[1] - s[i]
    elseif i == 3
        v1 = s[2] - s[i]
        v2 = s[1] - s[i]
    end
    a = angle(v1,v2)
    a < pi/2 ? a : pi - a
end

