immutable Vec{N, T} <: FixedVector{N, T}
    _::NTuple{N, T}
end
immutable Point{N, T} <: FixedVector{N, T}
    _::NTuple{N, T}
end
immutable Normal{N, T} <: FixedVector{N, T}
    _::NTuple{N, T}
end
immutable TextureCoordinate{N, T} <: FixedVector{N, T}
    _::NTuple{N, T}
end
immutable Face{N, T, IndexOffset} <: FixedVector{N, T}
    _::NTuple{N, T}
end

abstract GeometryPrimitive #abstract type for primitives


immutable HyperRectangle{N, T} <: GeometryPrimitive
    minimum::Vec{N, T}
    maximum::Vec{N, T}
end

immutable HyperCube{N, T} <: GeometryPrimitive
    origin::Vec{N, T}
    width::Vec{N, T}
end


immutable HyperSphere{N, T} <: GeometryPrimitive
    center::Point{N, T}
    r::T
end

typealias Cube{T}   HyperCube{3, T}
typealias Circle{T} HyperSphere{2, T}
typealias Sphere{T} HyperSphere{3, T}

typealias AbsolutRectangle{T} HyperRectangle{2, T}
typealias AABB{T} HyperRectangle{3, T}


immutable Rectangle{T} <: GeometryPrimitive
    x::T
    y::T
    w::T
    h::T
end


immutable Quad{T} <: GeometryPrimitive
    downleft::Vec{3, T}
    width   ::Vec{3, T}
    height  ::Vec{3, T}
end

immutable Pyramid{T} <: GeometryPrimitive
    middle::Point{3, T}
    length::T
    width ::T
end
