module Orthotopes
using Compat

export AbstractOrthotope, Orthotope, update!

abstract AbstractOrthotope{T, N}

type Orthotope{T, N} <: AbstractOrthotope{T, N}
    min::Vector{T}
    max::Vector{T}
end

function Orthotope{T}(max::Vector{T}, min::Vector{T})
    n = length(max)
    m = length(min)
    @assert n == m
    Orthotope{T, n}(min, max)
end

function Orthotope(t::DataType, n::Int)
    max = fill(typemin(t), n)
    min = fill(typemax(t), n)
    Orthotope{t,n}(min, max)
end

@inline Base.max(b::Orthotope) = b.max
@inline Base.min(b::Orthotope) = b.min

function update!{T, N}(b::Orthotope{T, N}, v)
    for i = 1:N
        b.max[i] = max(b.max[i], v[i])
        b.min[i] = min(b.min[i], v[i])
    end
end

function (==){T1, T2, N}(b1::Orthotope{T1, N}, b2::Orthotope{T2, N})
    b1.min == b2.min && b1.max == b2.max
end

@inline isequal(b1::Orthotope, b2::Orthotope) = b1 == b2

function Base.contains{T1, T2, N}(b1::Orthotope{T1,N}, b2::Orthotope{T2, N})
    for i = 1:N
        b2.max[i] <= b1.max[i] && b2.min[i] >= b1.min[i] || return false
    end
    true
end

@inline Base.in(b1::Orthotope, b2::Orthotope) = contains(b2, b1)

function during{T1, T2, N}(b1::Orthotope{T1,N}, b2::Orthotope{T2, N})
    for i = 1:N
        b1.max[i] < b2.max[i] && b1.min[i] > b2.min[i] || return false
    end
    true
end

function starts{T1, T2, N}(b1::Orthotope{T1,N}, b2::Orthotope{T2, N})
    b1.min == b2.min
end

function finishes{T1, T2, N}(b1::Orthotope{T1,N}, b2::Orthotope{T2, N})
    b1.max == b2.max
end

function meets{T1, T2, N}(b1::Orthotope{T1,N}, b2::Orthotope{T2, N})
    b1.min == b2.max || b1.max == b2.min
end

end # module
