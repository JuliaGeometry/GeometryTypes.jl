#
# http://en.wikipedia.org/wiki/Allen%27s_interval_algebra
#

function before(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) where {T1, T2, N}
    for i = 1:N
        maximum(b1)[i] < minimum(b2)[i] || return false
    end
    true
end

@inline function meets(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) where {T1, T2, N}
    maximum(b1) == minimum(b2)
end

function overlaps(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) where {T1, T2, N}
    for i = 1:N
        maximum(b2)[i] > maximum(b1)[i] > minimum(b2)[i] &&
        minimum(b1)[i] < minimum(b2)[i] || return false
    end
    true
end

function starts(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) where {T1, T2, N}
    if minimum(b1) == minimum(b2)
        for i = 1:N
            maximum(b1)[i] < maximum(b2)[i] || return false
        end
        return true
    else
        return false
    end
end

function during(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) where {T1, T2, N}
    for i = 1:N
        maximum(b1)[i] < maximum(b2)[i] && minimum(b1)[i] > minimum(b2)[i] ||
        return false
    end
    true
end

function finishes(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) where {T1, T2, N}
    if maximum(b1) == maximum(b2)
        for i = 1:N
            minimum(b1)[i] > minimum(b2)[i] || return false
        end
        return true
    else
        return false
    end
end

#
# Containment
#


function isinside(rect::SimpleRectangle, x::Real, y::Real)
    rect.x <= x && rect.y <= y && rect.x + rect.w >= x && rect.y + rect.h >= y
end

function isinside(c::Circle, x::Real, y::Real)
    @inbounds ox,oy = origin(c)
    xD = abs(ox - x)
    yD = abs(oy - y)
    xD <= c.r && yD <= c.r
end


"""
contains(s::Simplex, pt; atol=0., rtol=defaulrtol(eltype(pt)))

Check if a point is contained inside a Simplex. If the intrinsic dimension
of the simplex is smaller then the dimension of the surrounding space
(for example a triangle in 3d) one needs the atol, rtol parameters.
"""
function contains(s::Simplex, pt; atol=0., rtol=Base.rtoldefault(eltype(pt)))
    w = weights(pt, s)
    all(w .>= -atol) || return false  # projection lies outside of s
    pt_proj = vertexmat(s) * w
    return isapprox(pt_proj, pt, atol=atol, rtol=rtol)
end

"""
Check if HyperRectangles are contained in each other. This does not use
strict inequality, so HyperRectangles may share faces and this will still
return true.
"""
function contains(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) where {T1, T2, N}
    for i = 1:N
        maximum(b2)[i] <= maximum(b1)[i] && minimum(b2)[i] >= minimum(b1)[i] ||
        return false
    end
    true
end

"""
Check if a point is contained in a HyperRectangle. This will return true if
the point is on a face of the HyperRectangle.
"""
function contains(b1::HyperRectangle{N, T}, pt::Union{FixedVector, AbstractVector}) where {T, N}
    for i = 1:N
        pt[i] <= maximum(b1)[i] && pt[i] >= minimum(b1)[i] || return false
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
in(pt::Union{FixedVector, AbstractVector}, b1::HyperRectangle) = contains(b1, pt)



#
# Equality
#

==(a::AbstractMesh, b::AbstractMesh) = false
function ==(a::M, b::M) where M <: AbstractMesh
    for ((ka, va), (kb, vb)) in zip(all_attributes(a), all_attributes(b))
        va != vb && return false
    end
    true
end

(==)(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) where {T1, T2, N} =
    minimum(b1) == minimum(b2) && widths(b1) == widths(b2)


isequal(b1::HyperRectangle, b2::HyperRectangle) = b1 == b2

isless(a::SimpleRectangle, b::SimpleRectangle) = isless(area(a), area(b))
