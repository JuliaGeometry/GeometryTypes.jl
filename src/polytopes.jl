function Base.call{N,T}(::Type{Polytope{N,T}}, elts...)
    Polytope{N,T}(T[elts...])
end

function Base.call{T}(::Type{Polygon}, elts::T...)
    Polygon{T}(T[elts...])
end

function Base.call{T}(::Type{Polyhedron}, elts::T...)
    Polyhedron{T}(T[elts...])
end
