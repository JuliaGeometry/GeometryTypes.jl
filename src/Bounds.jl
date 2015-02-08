module Bounds

abstract AbstractBounds{T, N}

type Bounds{T, N<:Int} <: AbstractBounds{T, N}
    min::Vector{T}
    max::Vector{T}
end

function Bounds{T}(max::Vector{T}, min::Vector{T})
    n = length(max)
    m = length(min)
    @assert n == m
    Bounds{T, n}(max, min)
end

max(b::Bounds) = b.max
min(b::Bounds) = b.min

function update!{T, N}(b::Bounds{T, N}, v)
    for i = 1:n
        b.max[i] = max(b.max[i], v[i])
        b.min[i] = min(b.min[i], v[i])
    end
end

end # module
