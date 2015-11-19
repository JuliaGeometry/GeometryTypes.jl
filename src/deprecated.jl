import Base: @deprecate, @deprecate_binding

@deprecate triangulate{F<:Face}(t::Type{F}, f::Face) decompose(t, f)

@deprecate call{N,T}(t::Type{Vector{Point{N,T}}}, r::HyperRectangle{N, T}) decompose(t, r)

@deprecate_binding Rectangle SimpleRectangle

# TODO
# These are very tightly coupled to HomogenousMesh.
getindex{PT}(r::SimpleRectangle, t::Type{Point{2, PT}}) = decompose(t, r)
getindex{PT}(p::Pyramid, t::Type{Point{3, PT}}) = decompose(t, p)
getindex{ET}(q::Quad, t::Type{Point{3, ET}}) = decompose(t, q)

