maximum(b::HyperRectangle) = b.maximum
minimum(b::HyperRectangle) = b.minimum
length{T, N}(b::HyperRectangle{N, T}) = N
width(b::HyperRectangle) = maximum(b) - minimum(b)

"""
Splits an HyperRectangle into two new ones along an axis at a given axis value
"""
split{N}(b::HyperRectangle{N, Bool}, a::Int, v::Bool) = split(b,a,v)
split{N,T<:Integer}(b::HyperRectangle{N, T}, a::Int, v::T) = split(b,a,v)
function split{N, T}(b::HyperRectangle{N, T}, axis::Int, value::T)
    b1max = setindex(b.maximum, value, axis)
    b2min = setindex(b.minimum, value, axis)

    return HyperRectangle{N, T}(b.minimum, b1max),
           HyperRectangle{N, T}(b2min, b.maximum)
end


call{T,N}(::Type{HyperRectangle{N, T}}) =
    HyperRectangle{N, T}(Vec{N,T}(typemin(T)), Vec{N,T}(typemax(T)))
