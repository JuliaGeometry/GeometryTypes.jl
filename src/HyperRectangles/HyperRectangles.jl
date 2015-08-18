using Compat

VERSION < v"0.4-" && using Docile

maximum(b::HyperRectangle) = b.maximum
minumum(b::HyperRectangle) = b.minumum
length{T, N}(b::HyperRectangle{T, N}) = N

(==){T1, T2, N}(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) =
    b1.min == b2.min && b1.max == b2.max


isequal(b1::HyperRectangle, b2::HyperRectangle) = b1 == b2

"""
Check if HyperRectangles are contained in each other. This does not use
strict inequality, so HyperRectangles may share faces and this will still
return true.
"""
function contains{T1, T2, N}(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2})
    for i = 1:N
        b2.max[i] <= b1.max[i] && b2.min[i] >= b1.min[i] || return false
    end
    true
end

"""
Check if a point is contained in a HyperRectangle. This will return true if
the point is on a face of the HyperRectangle.
"""
function contains{T, T1, N}(b1::HyperRectangle{N, T}, pt::Vec{N, T1})
    for i = 1:N
        pt[i] <= b1.max[i] && pt[i] >= b1.min[i] || return false
    end
    true
end

"""
Check if HyperRectangles are contained in each other. This does not use
strict inequality, so HyperRectangles may share faces and this will still
return true.
"""
in(b1::HyperRectangle, b2::HyperRectangle) = contains(b2, b1)

"""
Check if a point is contained in a HyperRectangle. This will return true if
the point is on a face of the HyperRectangle.
"""
in(pt::AbstractVector, b1::HyperRectangle) = contains(b1, pt)

"""
Splits an HyperRectangle into two new ones along an axis at a given axis value
"""
#=
function split{T, N}(b::HyperRectangle{N, T}, axis::Int, value::T)
    b1max = copy(b.max)
    b1max[axis] = value

    b2min = copy(b.min)
    b2min[axis] = value

    return HyperRectangle{T, N}(copy(b.min), b1max),
           HyperRectangle{T, N}(b2min, copy(b.max))
end
=#
"""
Perform a union between two HyperRectangles.
"""
union{T,N}(h1::HyperRectangle{N, T}, h2::HyperRectangle{N, T}) =
    HyperRectangle{T,N}(min(h1.min, h2.min), max(h1.max, h2.max))

"""
Perform a difference between two HyperRectangles.
"""
diff(h1::HyperRectangle, h2::HyperRectangle) = h1



"""
Perform a intersection between two HyperRectangles.
"""
intersect{T,N}(h1::HyperRectangle{N, T}, h2::HyperRectangle{N, T}) =
    HyperRectangle{T,N}(max(h1.min, h2.min),  min(h1.max, h2.max))


if VERSION >= v"0.4.0-"
    call{T,N}(::Type{HyperRectangle{N, T}}) =
        HyperRectangle{T,N}(Vec{N,T}(typemin(T)), Vec{N,T}(typemax(T)))
end

# submodules
include("Relations.jl")
include("Operations.jl")
