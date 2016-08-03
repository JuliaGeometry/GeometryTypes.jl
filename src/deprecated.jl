import Base: @deprecate, @deprecate_binding

@deprecate triangulate{F<:Face}(t::Type{F}, f::Face) decompose(t, f)


@deprecate convert{N1, N2, T1, T2}(::Type{HyperRectangle{N1, T1}},
                                   geometry::Array{Point{N2, T2}}) HyperRectangle{N1,T1}(geometry::Array{Point{N2, T2}})

@deprecate_binding Rectangle SimpleRectangle

# TODO
# These are very tightly coupled to HomogenousMesh.
getindex{PT}(r::SimpleRectangle, t::Type{Point{2, PT}}) = decompose(t, r)
getindex{PT}(p::Pyramid, t::Type{Point{3, PT}}) = decompose(t, p)
getindex{ET}(q::Quad, t::Type{Point{3, ET}}) = decompose(t, q)
decompose{X}(t::Type{X}, m::AbstractMesh) = m[t]
