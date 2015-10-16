update{N, T, T2}(b::HyperRectangle{N, T}, v::Vec{N, T2}) = update(b, Vec{N, T}(v))
update{N, T}(b::HyperRectangle{N, T}, v::Vec{N, T}) = 
    HyperRectangle{N, T}(min(b.minimum, v), max(b.maximum, v))

# Min maximum distance functions between hrectangle and point for a given dimension
@inline min_dist_dim{N, T}(rect::HyperRectangle{N, T}, p::Vec{N, T}, dim::Int) = 
    max(zero(T), max(rect.minimum[dim] - p[dim], p[dim] - rect.maximum[dim]))

@inline max_dist_dim{N, T}(rect::HyperRectangle{N, T}, p::Vec{N, T}, dim::Int) =
    max(rect.maximum[dim] - p[dim], p[dim] - rect.minimum[dim])

@inline min_dist_dim{N, T}(rect1::HyperRectangle{N, T}, rect2::HyperRectangle{N, T}, dim::Int) = 
    max(zero(T), max(rect1.minimum[dim] - rect2.maximum[dim], rect2.minimum[dim] - rect1.maximum[dim]))

@inline max_dist_dim{N, T}(rect1::HyperRectangle{N, T},  rect2::HyperRectangle{N, T}, dim::Int) = 
    max(rect1.maximum[dim] - rect2.minimum[dim],  rect2.maximum[dim] - rect1.minimum[dim])


# Total minimum maximum distance functions
@inline function min_euclideansq{N, T}(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}})
    minimum_dist = T(0.0)
    for dim in 1:length(p)
        d = min_dist_dim(rect, p, dim)
        minimum_dist += d*d
    end
    return minimum_dist
end
min_euclidean{N, T}(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}}) = sqrt(min_euclideansq(rect, p))


@inline function max_euclideansq{N, T}(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}})
    maximum_dist = T(0.0)
    for dim in 1:length(p)
        d = max_dist_dim(rect, p, dim)
        maximum_dist += d*d
    end
    return maximum_dist
end
max_euclidean{N, T}(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}}) = sqrt(max_euclideansq(rect, p))


# Functions that return both minimum and maximum for convenience
@inline function minmax_dist_dim{N, T}(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}}, dim::Int)
    minimum_d = min_dist_dim(rect, p, dim)
    maximum_d = max_dist_dim(rect, p, dim)
    return minimum_d, maximum_d
end


@inline function minmax_euclideansq{N, T}(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}})
    minimum_dist = min_euclideansq(rect, p)
    maximum_dist = max_euclideansq(rect, p)
    return minimum_dist, maximum_dist
end

function minmax_euclidean{N, T}(rect::HyperRectangle{N, T}, p::Union{Vec{N, T}, HyperRectangle{N, T}})
    minimumsq, maximumsq = minmax_euclideansq(rect, p)
    return sqrt(minimumsq), sqrt(maximumsq)
end
