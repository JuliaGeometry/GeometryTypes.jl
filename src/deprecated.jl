import Base.@deprecate

@deprecate triangulate{F<:Face}(t::Type{F}, f::Face) decompose(t, f)

@deprecate call{T}(t::Type{Vector{Point{3,T}}}, r::HyperRectangle{3, T}) decompose(t, r)
@deprecate call{T}(t::Type{Vector{Point{2,T}}}, r::HyperRectangle{2, T}) decompose(t, r)


# TODO
# These are very tightly coupled to HomogenousMesh.
getindex{PT}(r::Rectangle, t::Type{Point{2, PT}}) = decompose(t, r)
getindex{PT}(p::Pyramid, t::Type{Point{3, PT}}) = decompose(t, p)
getindex{ET}(q::Quad, t::Type{Point{3, ET}}) = decompose(t, q)

