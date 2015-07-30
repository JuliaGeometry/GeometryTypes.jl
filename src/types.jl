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
for name in [:Vec, :Point, :Normal, :TextureCoordinate, :Face ]
    eval(quote
        call{N, T}(::Type{$name{N, T}}, a::Real) = $name(ntuple(FixedSizeArrays.ConstFunctor(a), Val{N}))
        call(::Type{$name}, a::AbstractVector) = $name(ntuple(FixedSizeArrays.IndexFunctor(a), Val{length(a)}))
    end)

end

#Axis Aligned Bounding Box
abstract GeometryPrimitive #abstract type for primitives


immutable HyperRectangle{T, N} <: GeometryPrimitive
    minimum::Vec{T, N}
    maximum::Vec{T, N}
end

immutable HyperCube{N, T} <: GeometryPrimitive
    origin::Vec{N, T}
    width::Vec{N, T}
end


immutable HyperSphere{N, T} <: GeometryPrimitive
    center::Point{N, T}
    r::T
end

typealias Cube{T} HyperCube{3, T}
typealias Circle{T} HyperSphere{2, T}
typealias Sphere{T} HyperSphere{3, T}

typealias Rectangle{T} HyperRectangle{2, T}
typealias AABB{T} HyperRectangle{3, T}


immutable Quad{T} <: GeometryPrimitive
    downleft::Vec{T}
    width   ::Vec{T}
    height  ::Vec{T}
end

immutable Pyramid{T} <: GeometryPrimitive
    middle::Point{3, T}
    length::T
    width ::T
end
