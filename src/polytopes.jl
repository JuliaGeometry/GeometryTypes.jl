function Base.call{T}(::Type{Polygon}, elts::T...)
    Polygon{T}(T[elts...])
end

function Base.call{T}(::Type{Polyhedron}, elts::T...)
    Polyhedron{T}(T[elts...])
end

elements(p::AbstractPolytope) = p.elements
