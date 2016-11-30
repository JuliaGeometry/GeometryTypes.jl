#
# We need this constructor to route around the FixedSizeArray `call` and
# so Simplex(Pt, Pt...) etc works. Hopefully these ambiguities will be fixed in
# forthcoming Julia versions.
function (::Type{S}){S <: Simplex}(sv::StaticVector)
    Simplex{1, typeof(sv)}((sv,))
end

@inline function (::Type{Simplex{S, T}}){S, T}(x)
    Simplex{S, T}(ntuple(i-> T(x), Val{S}))
end
@inline function (::Type{Simplex{S}}){S, T}(x::T)
    Simplex{S, T}(ntuple(i-> x, Val{S}))
end
@inline function (::Type{Simplex{1, T}}){T}(x::T)
    Simplex{1, T}((x,))
end
@inline (::Type{Simplex}){S}(x::NTuple{S}) = Simplex{S}(x)
@inline function (::Type{Simplex{S}}){S, T <: Tuple}(x::T)
    Simplex{S, StaticArrays.promote_tuple_eltype(T)}(x)
end

Base.@pure Base.size{S}(::Union{Simplex{S}, Type{Simplex{S}}}) = (S, )
Base.@pure Base.size{S,T}(::Type{Simplex{S, T}}) = (S,)

Base.@propagate_inbounds function Base.getindex(v::Simplex, i::Integer)
    v.data[i]
end
@inline Base.Tuple(v::Simplex) = v.data
@inline Base.convert{S, T}(::Type{Simplex{S, T}}, x::NTuple{S, T}) = Simplex{S, T}(x)
# @inline Base.convert{SV <: Simplex}(::Type{SV}, x::StaticVector) = SV(x)
@inline function Base.convert{S, T}(::Type{Simplex{S, T}}, x::Tuple)
    Simplex{S, T}(convert(NTuple{S, T}, x))
end
# StaticArrays.similar_type{SV <: Simplex}(::Union{SV, Type{SV}}) = Simplex
# function StaticArrays.similar_type{SV <: Simplex, T}(::Union{SV, Type{SV}}, ::Type{T})
#     Simplex{length(SV), T}
# end
# function StaticArrays.similar_type{SV <: Simplex}(::Union{SV, Type{SV}}, s::Tuple{Int})
#     Simplex{s[1], eltype(SV)}
# end
function StaticArrays.similar_type{SV <: Simplex, T}(::Union{SV, Type{SV}}, ::Type{T}, s::Tuple{Int})
    Simplex{s[1], T}
end

# @compat (::Type{S}){S <: Simplex}(fs::FlexibleSimplex) = convert(S, fs)
#
# # FSA doesn't handle symbols for length 1 well.
# @compat function (::Type{T}){T <: Simplex}(f::Symbol)
#     Simplex{1 ,Symbol}((f,))
# end



"""
volume_unnormalized(s::Simplex)

Return volume of s, normalized such that the simplex spanned
by the origin and unit vectors has volume 1.
"""
function volume_unnormalized(s::Simplex)
    es = edgespan(s); √(det(es'*es))
end


"""
volume(s::Simplex)

Return the volume of a geometric object.
"""
volume(s::Simplex) = volume_unnormalized(s) / factorial(nvertices(s)-1)

"""
w = weights(pt, s::Simplex)

If pt is a point inside s, w is such that
sum(w .* vertices(s)) = pt.
This is still true, if pt just lies inside the affine subspace spanned by s.
For general point pt, we only have
sum(w .* vertices(s)) = projection of pt onto affine subspace spanned by s.
"""
function weights(pt, s::Simplex)
    wp = pinvli(edgespan(s)) * (pt - translation(s))
    unshift(wp, 1-sum(wp))
end

translation(s::Simplex) = first(vertices(s))

@generated function edgespan{m, T}(s::Simplex{m, T})
    M = m - 1; N = length(T)
    ET = eltype(T)
    init = quote
        vert = vertices(s)
        v1 = vert[1]
    end
    tupl = Expr(:tuple)
    for i = 2:m
        sym = Symbol("diff$i")
        push!(init.args, :($sym = vert[$i]-v1))
        append!(tupl.args, (:($sym[$j]) for j = 1:N))
    end
    quote
        $init
        return Mat{$N, $M, $ET, $(M*N)}($tupl)
    end
end

"""
simplex_face(s::Simplex, i::Int)::Simplex

Return the face opposite to ith vertex of simplex.
"""
simplex_face(s::Simplex, i::Int) = Simplex(deleteat(vertices(s), i))

"""
proj_sqdist{T}(pt::T, s::LineSegment{T}, best_sqd=eltype(T)(Inf))
"""
function proj_sqdist{T}(pt::T, s::LineSegment{T}, best_sqd=eltype(T)(Inf))
    v0, v1 = vertices(s)
    pt = pt - v0
    v = v1 - v0
    θ = clamp(dot(v,pt)/sqnorm(v), zero(eltype(T)), one(eltype(T)))
    pt_proj = θ*v
    best_sqd = min(sqdist(pt, pt_proj), best_sqd)
    return pt_proj + v0, best_sqd
end

"""
pt_proj, sqd = proj_sqdist{nv,T}(pt::T, s::Simplex{nv,T}, best_sqd=eltype(T)(Inf))

# parameters

* pt, s: A point and a simplex, of which we want to know the (minimal) square distance.
* best_sqd: A bound on the distance. If the actual distance is greater then this,
search for the closest point is canceled asap.


# Return

* pt_proj is a point inside s, with minimal distance to pt. If the actual square
distance is greater then best_sqd, the behaviour of pt_proj is not defined.
* sqd is the square of the euclidean distance between pt, s. If the actual square
distance is greater then best_sqd is returned instead.

"""
function proj_sqdist{nv,T}(pt::T, s::Simplex{nv,T}, best_sqd = eltype(T)(Inf))
    w = weights(pt, s)
    best_proj = Vec(vertexmat(s) * w)
    # at this point best_proj lies in the subspace spanned by s,
    # but not necessarily inside s
    sqd = sqdist(pt, best_proj)
    if sqd >= best_sqd  # pt is far away even from the subspace spanned by s
        return best_proj, best_sqd
    elseif any(w .< 0)  # pt is closest to point inside a face of s
        @inbounds for i in 1:length(w)
            if w[i] < 0
                proj, sqd = proj_sqdist(pt, simplex_face(s, i), best_sqd)
                if sqd < best_sqd
                    best_sqd = sqd
                    best_proj = proj
                end
            end
        end
        return best_proj, best_sqd
    else # proj lies in the interiour of s
        return best_proj, sqd
    end
end

sqdist(pt, s, best = Inf) = proj_sqdist(pt, s, best)[2]

"""
proj_sqdist(p::Vec, q::Vec, best_sqd=eltype(p)(Inf))
"""
@inline function proj_sqdist(p::Vec, q::Vec, best_sqd = eltype(p)(Inf))
    q, min(best_sqd, sqnorm(p-q))
end
"""
proj_sqdist{T}(pt::T, s::Simplex{1, T}, best_sqd=eltype(T)(Inf))
"""
@inline function proj_sqdist{T}(pt::T, s::Simplex{1, T}, best_sqd=eltype(T)(Inf))
    proj_sqdist(pt, translation(s), best_sqd)
end
