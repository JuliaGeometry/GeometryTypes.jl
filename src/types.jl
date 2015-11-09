abstract AbstractDistanceField
abstract AbstractUnsignedDistanceField <: AbstractDistanceField
abstract AbstractSignedDistanceField <: AbstractDistanceField
abstract AbstractMesh{VertT, FaceT}
"""
Abstract to categorize geometry primitives of dimensionality `N`.
"""
abstract GeometryPrimitive{N}


"""
Abstract to classify Simplices. The convention for N starts at 1, which means
a Simplex has 1 point. A 2-simplex has 2 points, and so forth. This convention
is not the same as most mathematical texts.
"""
abstract AbstractSimplex{N,T} <: FixedVector{N,T}


"""
A `Simplex` is a generalization of an N-dimensional tetrahedra and can be thought
of as a minimal convex set containing the specified points.

* A 0-simplex is a point.
* A 1-simplex is a line segment.
* A 2-simplex is a triangle.
* A 3-simplex is a tetrahedron.

Note that this datatype is offset by one compared to the traditional
mathematical terminology. So a one-simplex is represented as `Simplex{2,T}`.
This is for a simpler implementation.

It applies to infinite dimensions. The sturucture of this type is designed
to allow embedding in higher-order spaces by parameterizing on `T`.
"""
immutable Simplex{N,T} <: AbstractSimplex{N,T}
    _::NTuple{N,T}
end

immutable Normal{N, T} <: FixedVector{N, T}
    _::NTuple{N, T}
end
immutable TextureCoordinate{N, T} <: FixedVector{N, T}
    _::NTuple{N, T}
end

"""
A Face is typically used when constructing subtypes of `AbstractMesh` where
the `Face` should not reproduce the vertices, but rather index into them.
Face is parameterized by:

* `N` - The number of vertices in the face.
* `T` - The type of the indices in the face, a subtype of Integer.
* `O` - The offset relative to Julia arrays. This helps reduce copying when
communicating with 0-indexed systems such ad OpenGL.
"""
immutable Face{N, T, IndexOffset} <: FixedVector{N, T}
    _::NTuple{N, T}
end

"""
A `HyperRectangle` is a generalization of a rectangle into N-dimensions.
Formally it is the cartesian product of intervals, which is represented by the
`minimum` and `maximum` fields, whose indices correspond to each of the `N` axes.
"""
immutable HyperRectangle{N, T} <: GeometryPrimitive{N}
    minimum::Vec{N, T}
    maximum::Vec{N, T}
end

immutable HyperCube{N, T} <: GeometryPrimitive{N}
    origin::Vec{N, T}
    width::Vec{N, T}
end

"""
A `HyperSphere` is a generalization of a sphere into N-dimensions.
A `center` and radius, `r`, must be specified.
"""
immutable HyperSphere{N, T} <: GeometryPrimitive{N}
    center::Point{N, T}
    r::T
end

immutable Rectangle{T} <: GeometryPrimitive{2}
    x::T
    y::T
    w::T
    h::T
end

immutable Quad{T} <: GeometryPrimitive{3}
    downleft::Vec{3, T}
    width   ::Vec{3, T}
    height  ::Vec{3, T}
end

immutable Pyramid{T} <: GeometryPrimitive{3}
    middle::Point{3, T}
    length::T
    width ::T
end

immutable Particle{N, T} <: GeometryPrimitive{N}
    position::Point{N, T}
    velocity::Vec{N, T}
end

"""
A `SignedDistanceField` is a uniform sampling of an implicit function.
The `bounds` field corresponds to the sampling space intervals on each axis.
The `data` field represents the value at each point whose exact location
can be rationalized from `bounds`.
The type is parameterized by:

* `N` - The dimensionality of the sampling space.
* `SpaceT` - the type of the space where we will uniformly sample.
* `FieldT` - the type resulting from evaluation of the implicit function.

Note that decoupling the space and field types is useful since geometry can
be formulated with integers and distances can be measured with floating points.
"""
type SignedDistanceField{N,SpaceT,FieldT} <: AbstractSignedDistanceField
    bounds::HyperRectangle{N,SpaceT}
    data::Array{FieldT,N}
end

"""
The `HomogenousMesh` type describes a polygonal mesh that is useful for
computation on the CPU or on the GPU.
All vectors must have the same length or must be empty, besides the face vector
Type can be void or a value, this way we can create many combinations from this
one mesh type.
This is not perfect, but helps to reduce a type explosion (imagine defining
every attribute combination as a new type).
"""
immutable HomogenousMesh{VertT, FaceT, NormalT, TexCoordT, ColorT, AttribT, AttribIDT} <: AbstractMesh{VertT, FaceT}
    vertices            ::Vector{VertT}
    faces               ::Vector{FaceT}
    normals             ::Vector{NormalT}
    texturecoordinates  ::Vector{TexCoordT}
    color               ::ColorT
    attributes          ::AttribT
    attribute_id        ::Vector{AttribIDT}
end

#Type aliases

"""
An alias for a one-simplex, corresponding to LineSegment{T} -> Simplex{2,T}.
"""
typealias LineSegment{T} Simplex{2,T}

typealias Triangle{T} Face{3, T, 0}
typealias GLFace{Dim} Face{Dim, Cuint, -1} #offset is relative to julia, so -1 is 0-indexed
typealias GLTriangle  Face{3, Cuint, -1}
typealias GLQuad      Face{4, Cuint, -1}

typealias Cube{T}   HyperCube{3, T}

"""
An alias for a HyperSphere of dimension 2. i.e. Circle{T} -> HyperSphere{2, T}
"""
typealias Circle{T} HyperSphere{2, T}
call(::Type{Circle}, x...) = HyperSphere(x...)
"""
An alias for a HyperSphere of dimension 3. i.e. Sphere{T} -> HyperSphere{3, T}
"""
typealias Sphere{T} HyperSphere{3, T}
call(::Type{Sphere}, x...) = HyperSphere(x...)

typealias AbsoluteRectangle{T} HyperRectangle{2, T}
typealias AABB{T} HyperRectangle{3, T}

typealias HMesh HomogenousMesh

typealias UV{T} TextureCoordinate{2, T}
typealias UVW{T} TextureCoordinate{3, T}

typealias PlainMesh{VT, FT} HMesh{Point{3, VT}, FT, Void, Void, Void, Void, Void}
typealias GLPlainMesh PlainMesh{Float32, GLTriangle}

typealias Mesh2D{VT, FT} HMesh{Point{2, VT}, FT, Void, Void, Void, Void, Void}
typealias GLMesh2D Mesh2D{Float32, GLTriangle}

typealias UVMesh{VT, FT, UVT} HMesh{Point{3, VT}, FT, Void, UV{UVT}, Void, Void, Void}
typealias GLUVMesh UVMesh{Float32, GLTriangle, Float32}

typealias UVWMesh{VT, FT, UVT} HMesh{Point{3, VT}, FT, Void, UVW{UVT}, Void, Void, Void}
typealias GLUVWMesh UVWMesh{Float32, GLTriangle, Float32}

typealias NormalMesh{VT, FT, NT} HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, Void, Void, Void}
typealias GLNormalMesh NormalMesh{Float32, GLTriangle, Float32}

typealias UVMesh2D{VT, FT, UVT} HMesh{Point{2, VT}, FT, Void, UV{UVT}, Void, Void, Void}
typealias GLUVMesh2D UVMesh2D{Float32, GLTriangle, Float32}

typealias NormalColorMesh{VT, FT, NT, CT} HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, CT, Void, Void}
typealias GLNormalColorMesh NormalColorMesh{Float32, GLTriangle, Float32, RGBA{Float32}}


typealias NormalAttributeMesh{VT, FT, NT, AT, A_ID_T} HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, Void, AT, A_ID_T}
typealias GLNormalAttributeMesh NormalAttributeMesh{Float32, GLTriangle, Float32, Vector{RGBA{U8}}, Float32}

typealias NormalUVWMesh{VT, FT, NT, UVT} HMesh{Point{3, VT}, FT, Normal{3, NT}, UVW{UVT}, Void, Void, Void}
typealias GLNormalUVWMesh NormalUVWMesh{Float32, GLTriangle, Float32, Float32}

typealias NormalUVMesh{VT, FT, NT, UVT} HMesh{Point{3, VT}, FT, Normal{3, NT}, UV{UVT}, Void, Void, Void}
typealias GLNormalUVMesh NormalUVMesh{Float32, GLTriangle, Float32, Float32}

