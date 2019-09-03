function centroid{T}(poly::Polygon{T})
    area = 0.0
    cent = zero(T)
    n = length(elements(poly))
    i = n
    @inbounds for j = 1:n
        v1 = elements(poly)[i]
        v2 = elements(poly)[j]
        d = v1[1]*v2[2]-v2[1]*v1[2]
        area += d
        cent += (v1+v2)*d
        i = j
    end
    return cent/(3*area)
end
