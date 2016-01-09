"""
```angle(a,b)```
Compute the angle of `b` relative to `a` in radians.
"""
function angle(a,b)
    v1 = normalize(a)
    v2 = normalize(b)
    atan2(v2[2],v2[1]) - atan2(v1[2], v1[1])
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
end

