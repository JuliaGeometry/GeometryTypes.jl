function update(b::HyperRectangle{N, T}, v::Vec{N, T2}) where {N, T, T2}
    update(b, Vec{N, T}(v))
end
function update(b::HyperRectangle{N, T}, v::Vec{N, T}) where {N, T}
    m = min.(minimum(b), v)
    maxi = maximum(b)
    mm = if isnan(maxi)
        v-m
    else
        max.(v, maxi) - m
    end
    HyperRectangle{N, T}(m, mm)
end

# Min maximum distance functions between hrectangle and point for a given dimension
@inline function min_dist_dim(rect::HyperRectangle{N, T}, p::Vec{N, T}, dim::Int) where {N, T}
    max(zero(T), max(minimum(rect)[dim] - p[dim], p[dim] - maximum(rect)[dim]))
end

@inline function max_dist_dim(rect::HyperRectangle{N, T}, p::Vec{N, T}, dim::Int) where {N, T}
    max(maximum(rect)[dim] - p[dim], p[dim] - minimum(rect)[dim])
end

@inline function min_dist_dim(rect1::HyperRectangle{N, T},
                              rect2::HyperRectangle{N, T},
                              dim::Int) where {N, T}
    max(zero(T), max(
        minimum(rect1)[dim] - maximum(rect2)[dim],
        minimum(rect2)[dim] - maximum(rect1)[dim]
    ))
end

@inline function max_dist_dim(rect1::HyperRectangle{N, T},
                              rect2::HyperRectangle{N, T},
                              dim::Int) where {N, T}
    max(
        maximum(rect1)[dim] - minimum(rect2)[dim],
        maximum(rect2)[dim] - minimum(rect1)[dim]
    )
end

# Total minimum maximum distance functions
@inline function min_euclideansq(rect::HyperRectangle{N, T},
                                 p::Union{Vec{N, T},
                                 HyperRectangle{N, T}}) where {N, T}
    minimum_dist = T(0.0)
    for dim in 1:length(p)
        d = min_dist_dim(rect, p, dim)
        minimum_dist += d*d
    end
    return minimum_dist
end

# could add an @symmetric macro, which defines min_euclidean(pt, s) from
# min_euclidean(s, pt) automatically etc.
@inline min_euclidean(pt1::Vec, pt2::Vec) = norm(pt1-pt2)
min_euclidean(pt::Vec, s::Simplex) = √(sqdist(pt, s))
min_euclidean(s::Simplex, pt::Vec) = min_euclidean(pt, s)
min_euclidean(r1::HyperRectangle, r2::Vec) = sqrt(min_euclideansq(r1, r2))
min_euclidean(r1::Vec, r2::HyperRectangle) = sqrt(min_euclideansq(r1, r2))
min_euclidean(r1::HyperRectangle, r2::HyperRectangle) = sqrt(min_euclideansq(r1, r2))
min_euclidean(c1::AbstractConvexHull, pt::Vec) = gjk(c1,pt)
min_euclidean(pt::Vec, c2::AbstractConvexHull) = gjk(pt,c2)
min_euclidean(c1::AbstractConvexHull, c2::AbstractConvexHull) = gjk(c1,c2)


@inline function max_euclideansq(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}}) where {N, T}
    maximum_dist = T(0.0)
    for dim in 1:length(p)
        d = max_dist_dim(rect, p, dim)
        maximum_dist += d*d
    end
    return maximum_dist
end
function max_euclidean(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}}) where {N, T}
    sqrt(max_euclideansq(rect, p))
end


# Functions that return both minimum and maximum for convenience
@inline function minmax_dist_dim(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}}, dim::Int) where {N, T}
    minimum_d = min_dist_dim(rect, p, dim)
    maximum_d = max_dist_dim(rect, p, dim)
    return minimum_d, maximum_d
end


@inline function minmax_euclideansq(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}}) where {N, T}
    minimum_dist = min_euclideansq(rect, p)
    maximum_dist = max_euclideansq(rect, p)
    return minimum_dist, maximum_dist
end

function minmax_euclidean(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}}) where {N, T}
    minimumsq, maximumsq = minmax_euclideansq(rect, p)
    return sqrt(minimumsq), sqrt(maximumsq)
end
