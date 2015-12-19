update{N, T, T2}(b::HyperRectangle{N, T}, v::Vec{N, T2}) =
    update(b, Vec{N, T}(v))
function update{N, T}(b::HyperRectangle{N, T}, v::Vec{N, T})
    m = min(minimum(b), v)
    mm = max(maximum(b), v)-m
    HyperRectangle{N, T}(m, mm)
end

# Min maximum distance functions between hrectangle and point for a given dimension
@inline min_dist_dim{N, T}(rect::HyperRectangle{N, T}, p::Vec{N, T}, dim::Int) = 
    max(zero(T), max(minimum(rect)[dim] - p[dim], p[dim] - maximum(rect)[dim]))

@inline max_dist_dim{N, T}(rect::HyperRectangle{N, T}, p::Vec{N, T}, dim::Int) =
    max(maximum(rect)[dim] - p[dim], p[dim] - minimum(rect)[dim])

@inline function min_dist_dim{N, T}(rect1::HyperRectangle{N, T},
                                    rect2::HyperRectangle{N, T},
                                    dim::Int)
    max(zero(T), max(minimum(rect1)[dim] - maximum(rect2)[dim],
                     minimum(rect2)[dim] - maximum(rect1)[dim]))
end

@inline function max_dist_dim{N, T}(rect1::HyperRectangle{N, T},
                                    rect2::HyperRectangle{N, T},
                                    dim::Int)
    max(maximum(rect1)[dim] - minimum(rect2)[dim],
        maximum(rect2)[dim] - minimum(rect1)[dim])
end

# Total minimum maximum distance functions
@inline function min_euclideansq{N, T}(rect::HyperRectangle{N, T},
                                       p::Union{Vec{N, T},
                                       HyperRectangle{N, T}})
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
