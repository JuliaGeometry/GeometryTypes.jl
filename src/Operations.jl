module Operations

using HyperRectangles
using Compat

export update!, points, min_dist_dim, max_dist_dim,  minmax_dist_dim, min_euclideansq,
       max_euclideansq, minmax_euclideansq,  min_euclidean,  max_euclidean,  minmax_euclidean

function update!{T, N}(b::HyperRectangle{T, N}, v)
    for i = 1:N
        b.max[i] = max(b.max[i], v[i])
        b.min[i] = min(b.min[i], v[i])
    end
end

function points{T}(rect::HyperRectangle{T, 3})
    Vector{T}[rect.min,
        [rect.min[1],rect.min[2],rect.max[3]],
        [rect.min[1],rect.max[2],rect.min[3]],
        [rect.min[1],rect.max[2],rect.max[3]],
        [rect.max[1],rect.min[2],rect.min[3]],
        [rect.max[1],rect.min[2],rect.max[3]],
        [rect.max[1],rect.max[2],rect.min[3]],
        rect.max]
end

function points{T}(rect::HyperRectangle{T, 2})
    Vector{T}[rect.min,
        [rect.min[1],rect.max[2]],
        [rect.max[1],rect.min[2]],
        rect.max]
end


# Min max distance functions between hrectangle and point for a given dimension
@inline function min_dist_dim{T}(rect::HyperRectangle{T}, p::Vector{T}, dim::Int)
    return max(zero(T), max(rect.min[dim] - p[dim], p[dim] - rect.max[dim]))
end

@inline function max_dist_dim{T}(rect::HyperRectangle{T}, p::Vector{T}, dim::Int)
    return max(rect.max[dim] - p[dim], p[dim] - rect.min[dim])
end

@inline function min_dist_dim{T}(rect1::HyperRectangle{T}, rect2::HyperRectangle{T}, dim::Int)
    return max(zero(T), max(rect1.min[dim] - rect2.max[dim], rect2.min[dim] - rect1.max[dim]))
end

@inline function max_dist_dim{T}(rect1::HyperRectangle{T},  rect2::HyperRectangle{T}, dim::Int)
    return max(rect1.max[dim] - rect2.min[dim],  rect2.max[dim] - rect1.min[dim])
end


typealias VecOrHRect{T} Union(Vector{T}, HyperRectangle{T})

# Total min max distance functions
@inline function min_euclideansq{T}(rect::HyperRectangle{T}, p::VecOrHRect{T})
    min_dist = 0.0
    for dim in 1:length(p)
        d = min_dist_dim(rect, p, dim)
        min_dist += d*d
    end
    return min_dist
end
min_euclidean{T}(rect::HyperRectangle{T}, p::VecOrHRect{T}) = sqrt(min_euclideansq(rect, p))


@inline function max_euclideansq{T}(rect::HyperRectangle{T}, p::VecOrHRect{T})
    max_dist = 0.0
    for dim in 1:length(p)
        d = max_dist_dim(rect, p, dim)
        max_dist += d*d
    end
    return max_dist
end
max_euclidean{T}(rect::HyperRectangle{T}, p::VecOrHRect{T}) = sqrt(max_euclideansq(rect, p))


# Functions that return both min and max for convenience
@inline function minmax_dist_dim{T}(rect::HyperRectangle{T}, p::VecOrHRect{T}, dim::Int)
    min_d = min_dist_dim(rect, p, dim)
    max_d = max_dist_dim(rect, p, dim)
    return min_d, max_d
end


@inline function minmax_euclideansq{T}(rect::HyperRectangle{T}, p::VecOrHRect{T})
    min_dist = min_euclideansq(rect, p)
    max_dist = max_euclideansq(rect, p)
    return min_dist, max_dist
end

function minmax_euclidean{T}(rect::HyperRectangle{T}, p::VecOrHRect{T})
    minsq, maxsq = minmax_euclideansq(rect, p)
    return sqrt(minsq), sqrt(maxsq)
end


end # module
