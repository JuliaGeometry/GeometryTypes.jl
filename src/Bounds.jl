module Bounds
using Compat

export AbstractBound, Bound, update!

abstract AbstractBound{T, N}

type Bound{T, N} <: AbstractBound{T, N}
    min::Vector{T}
    max::Vector{T}
end

function Bound{T}(max::Vector{T}, min::Vector{T})
    n = length(max)
    m = length(min)
    @assert n == m
    Bound{T, n}(min, max)
end

function Bound(t::DataType, n::Int)
    max = fill(typemin(t), n)
    min = fill(typemax(t), n)
    Bound{t,n}(min, max)
end

@inline Base.max(b::Bound) = b.max
@inline Base.min(b::Bound) = b.min

function update!{T, N}(b::Bound{T, N}, v)
    for i = 1:N
        b.max[i] = max(b.max[i], v[i])
        b.min[i] = min(b.min[i], v[i])
    end
end

function (==){T1, T2, N}(b1::Bound{T1, N}, b2::Bound{T2, N})
    b1.min == b2.min && b1.max == b2.max || return false
    return true
end

@inline isequal(b1::Bound, b2::Bound) = b1 == b2

function Base.contains{T1, T2, N}(b1::Bound{T1,N}, b2::Bound{T2, N})
    for i = 1:N
        b2.max[i] <= b1.max[i] && b2.min[i] >= b1.min[i] || return false
    end
    return true
end

@inline Base.in(b1::Bound, b2::Bound) = contains(b2, b1)

end # module
