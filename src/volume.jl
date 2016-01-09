"""
```volume(poly::Polygon)```

Calculate the volume, commonly "area", of a Polygon. Always returns a `Float64`.

Note the area is signed, so a Clockwise
oriented polygon has a negative value, and a Counter Clockwise oriented
polygon will have a positive value.
"""
function volume(poly::Polygon)
    area = 0.0
    n = length(elements(poly))
    n < 3 && return 0.0
    i = n
    @inbounds for j = 1:n
        v1 = elements(poly)[j]
        v2 = elements(poly)[i]
        area += v1[1]*v2[2]-v2[1]*v1[2]
        i = j
    end
    return area/2
end

volume(a::SimpleRectangle) = a.w*a.h

function volume{N,T}(s::HyperSphere{N,T})
    if iseven(N)
        const K = div(N, 2)
        return pi^K*radius(s)^N/factorial(K)
    else # odd
        const K = div(N-1,2)
        return 2*factorial(K)*(4pi)^K*radius(s)^(N)/factorial(N)
    end
end
