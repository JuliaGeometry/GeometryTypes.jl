function centroid{T}(poly::Polygon{T})
    area = 0.0
    c = zero(T)
    n = length(elements(poly))
    i = n
    @inbounds for j = 1:n
        p = elements(poly)[i]
        n = elements(poly)[j]
        d = p[1]*n[2]-n[1]*p[2]
        area += d
        c += (p+n)*d
        i = j
    end
    return c/3*a
end
