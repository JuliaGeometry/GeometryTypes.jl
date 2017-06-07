# implementaion of gjk algorithm
# https://en.wikipedia.org/wiki/Gilbert%E2%80%93Johnson%E2%80%93Keerthi_distance_algorithm

using Base.Cartesian

type_immutable(::Type{FlexibleSimplex{T}}, ::Type{Val{n}}) where {T,n}= Simplex{n,T}
type_immutable(s, v=Val{length(s)}) = type_immutable(typeof(s), v)
make_immutable(s, v=Val{length(s)}) = convert(type_immutable(s, v), s)

#@generated function with_immutable{n}(f, s, max_depth::Type{Val{n}}=Val{10})
#    quote
#        l = length(s)
#        @nif $n d->(d == l) d->(f(make_immutable(s, Val{d}))) d->error("length(s) = $s < max_depth = {n}")
#    end
#end

"""
with_immutable{n}(f, s, max_depth::Type{Val{n}}=Val{10})

Apply function f to immutable variant of s without introducing a type instability.
"""
function with_immutable(f, s)
    l = length(s)
    if l == 1
        f(make_immutable(s, Val{1}))
    elseif l == 2
        f(make_immutable(s, Val{2}))
    elseif l == 3
        f(make_immutable(s, Val{3}))
    elseif l == 4
        f(make_immutable(s, Val{4}))
    else
        f(make_immutable(s, Val{l}))
    end
end

function proj_sqdist(pt, fs::FlexibleSimplex)
    with_immutable(fs) do s
        proj_sqdist(pt, s)
    end::Tuple{eltype(fs), numtype(fs)}
end

function weights(pt, fs::FlexibleSimplex)
    with_immutable(fs) do s
        weights(pt, s)
    end
end

"""
MinkowskiDifference(c1, c2)

Represents the Minkowski difference of c1, c2.
"""
struct MinkowskiDifference{S,T}
    c1::S
    c2::T
end

⊖(c1,c2) = MinkowskiDifference(c1,c2)
convert(::FlexibleConvexHull, md::MinkowskiDifference) = FlexibleConvexHull(vertices(md))

function vertices(m::MinkowskiDifference)
    # There might be redundant vertices, should we try
    # to get rid of them?
    c1, c2 = m.c1, m.c2
    T = promote_type(eltype(c1), eltype(c2))
    verts = T[]
    for v1 in vertices(c1), v2 in vertices(c2)
        push!(verts, v1-v2)
    end
    verts
end

any_inside(c::AbstractConvexHull) = first(vertices(c))
any_inside(m::MinkowskiDifference) = any_inside(m.c1) - any_inside(m.c2)
any_inside(c::Union{HyperCube, HyperRectangle}) = origin(c)
any_inside(v::Vec) = v

support_vector_max(ch::AbstractConvexHull, v) = argmax(x-> x⋅v, vertices(ch))
support_vector_max(w::Vec, v) = w, w⋅v
function support_vector_max(c::HyperRectangle, v)
    s = widths(c)
    takes = map(x -> x > zero(eltype(v)), s .* v)
    best_pt::typeof(v) = origin(c) + takes.*s
    score = (best_pt ⋅ v)
    return best_pt, score
end
support_vector_max(c::HyperCube) = support_vector_max(HyperRectangle(c))

function support_vector_max(m::MinkowskiDifference, v)
    v1, score1 =  support_vector_max(m.c1, v)
    v2, score2 =  support_vector_max(m.c2, -v)
    v1 - v2, score1 + score2
end
support_vector(ch, v) = support_vector_max(ch,v)[1]

"""
    s = shrink!(s::FlexibleSimplex, pt, atol=0.)

Drop as many vertices from s as possible, while keeping pt inside.
"""
function shrink!(s::FlexibleSimplex, pt, atol=0.)
    (nvertices(s) <= 1) && return s
    w = weights(pt, s)
    @assert all(w .>= -atol)
    for i in length(w):-1:1
        w[i] .<= atol && deleteat!(s, i)
    end
    s
end


"""
    pt_best, dist = gjk0(c)

Compute the distance of a convex set to the origin using gjk algorithm. If c
is not convex, the algorithm may or may not yield an optimal solution.

# Arguments
* c needs to implement the following methods:

1. pt = any_inside(c): returns a point that is guaranteed to lie inside c.

2. best_pt, best_score = support_vector_max(c, v): returns a point inside c,
which has maximal scalar product with v.

# Return
* dist: distance from c to the origin.
* pt_best: point inside c realizing dist.
"""
function gjk0(c,
        atol = 1e-6,
        max_iter = 100,
        pt_best = any_inside(c)
    )
    @assert atol >= 0

    T = typeof(pt_best)
    zero_point = zero(T)
    sim = FlexibleSimplex(T[])
    for k in 1:max_iter
        direction = -pt_best
        wk, score = support_vector_max(c, direction)
        if (score <= (pt_best ⋅ direction) + atol) # pt_best is already most extreme
            return pt_best, norm(pt_best)
        else
            push!(sim, wk)
            pt_best::T, sqd = proj_sqdist(zero_point, sim)
            sqd == 0 && return pt_best, norm(pt_best)
            shrink!(sim, pt_best, atol)
        end
    end
    pt_best, norm(pt_best)
end

"""
dist = gjk(c1,c2, args...)

Compute the euclidean between two convex sets using gjk algorithm. See gjk0.
"""
function gjk(c1,c2, args...)
    # can tweak this to also reconstruct pt1 in ch1, pt2 in ch2,
    # which realize dist?
    m = c1 ⊖ c2
    pt_best, dist = gjk0(m, args...)
    dist
end
