
export update!, points, min_dist_dim, max_dist_dim,  minmax_dist_dim, min_euclideansq,
       max_euclideansq, minmax_euclideansq,  min_euclidean,  max_euclidean,  minmax_euclidean

update{N, T}(b::HyperRectangle{N, T}, v::Vec{N, T}) = 
    HyperRectangle{N, T}(min(b.min[i], v[i]), max(b.max, v))

points{T}(rect::HyperRectangle{3, T}) = Vec{3, T}[rect.min,
    Vec{3, T}(rect.min[1],rect.min[2],rect.max[3]),
    Vec{3, T}(rect.min[1],rect.max[2],rect.min[3]),
    Vec{3, T}(rect.min[1],rect.max[2],rect.max[3]),
    Vec{3, T}(rect.max[1],rect.min[2],rect.min[3]),
    Vec{3, T}(rect.max[1],rect.min[2],rect.max[3]),
    Vec{3, T}(rect.max[1],rect.max[2],rect.min[3]),
    rect.max
]

points{T}(rect::HyperRectangle{2, T}) = Vec{2, T}[
    rect.min,
    Vec{2, T}(rect.min[1],rect.max[2]),
    Vec{2, T}(rect.max[1],rect.min[2]),
    rect.max
]


# Min max distance functions between hrectangle and point for a given dimension
@inline min_dist_dim{N, T}(rect::HyperRectangle{N, T}, p::Vec{N, T}, dim::Int) = 
    max(zero(T), max(rect.min[dim] - p[dim], p[dim] - rect.max[dim]))

@inline max_dist_dim{N, T}(rect::HyperRectangle{N, T}, p::Vec{N, T}, dim::Int) =
    max(rect.max[dim] - p[dim], p[dim] - rect.min[dim])

@inline min_dist_dim{N, T}(rect1::HyperRectangle{N, T}, rect2::HyperRectangle{T}, dim::Int) = 
    max(zero(T), max(rect1.min[dim] - rect2.max[dim], rect2.min[dim] - rect1.max[dim]))

@inline max_dist_dim{N, T}(rect1::HyperRectangle{N, T},  rect2::HyperRectangle{T}, dim::Int) = 
    max(rect1.max[dim] - rect2.min[dim],  rect2.max[dim] - rect1.min[dim])


typealias VecOrHRect{N, T} Union(Vec{N, T}, HyperRectangle{N, T})

# Total min max distance functions
@inline function min_euclideansq{N, T}(rect::HyperRectangle{N, T}, p::VecOrHRect{N, T})
    min_dist = T(0.0)
    for dim in 1:length(p)
        d = min_dist_dim(rect, p, dim)
        min_dist += d*d
    end
    return min_dist
end
min_euclidean{N, T}(rect::HyperRectangle{N, T}, p::VecOrHRect{N, T}) = sqrt(min_euclideansq(rect, p))


@inline function max_euclideansq{N, T}(rect::HyperRectangle{N, T}, p::VecOrHRect{N, T})
    max_dist = T(0.0)
    for dim in 1:length(p)
        d = max_dist_dim(rect, p, dim)
        max_dist += d*d
    end
    return max_dist
end
max_euclidean{N, T}(rect::HyperRectangle{N, T}, p::VecOrHRect{N, T}) = sqrt(max_euclideansq(rect, p))


# Functions that return both min and max for convenience
@inline function minmax_dist_dim{N, T}(rect::HyperRectangle{N, T}, p::VecOrHRect{N, T}, dim::Int)
    min_d = min_dist_dim(rect, p, dim)
    max_d = max_dist_dim(rect, p, dim)
    return min_d, max_d
end


@inline function minmax_euclideansq{N, T}(rect::HyperRectangle{N, T}, p::VecOrHRect{N, T})
    min_dist = min_euclideansq(rect, p)
    max_dist = max_euclideansq(rect, p)
    return min_dist, max_dist
end

function minmax_euclidean{N, T}(rect::HyperRectangle{N, T}, p::VecOrHRect{N, T})
    minsq, maxsq = minmax_euclideansq(rect, p)
    return sqrt(minsq), sqrt(maxsq)
end
