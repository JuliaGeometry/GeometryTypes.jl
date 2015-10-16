abstract AbstractDistanceField
abstract AbstractUnsignedDistanceField <: AbstractDistanceField
abstract AbstractSignedDistanceField <: AbstractDistanceField
abstract AbstractMesh{VertT, FaceT}
"""
Abstract to categorize geometry primitives of dimensionality `N`.
"""
abstract GeometryPrimitive{N}


immutable Normal{N, T} <: FixedVector{N, T}
    _::NTuple{N, T}
end
immutable TextureCoordinate{N, T} <: FixedVector{N, T}
    _::NTuple{N, T}
end
immutable Face{N, T, IndexOffset} <: FixedVector{N, T}
    _::NTuple{N, T}
end

immutable HyperRectangle{N, T} <: GeometryPrimitive{N}
    minimum::Vec{N, T}
    maximum::Vec{N, T}
end

immutable HyperCube{N, T} <: GeometryPrimitive{N}
    origin::Vec{N, T}
    width::Vec{N, T}
end

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
A DistanceField of dimensionality `N`, is parameterized by the Space and
Field types.
"""
type SignedDistanceField{N,SpaceT,FieldT} <: AbstractSignedDistanceField
    bounds::HyperRectangle{N,SpaceT}
    data::Array{FieldT,N}
end

"""
All vectors must have the same length or must be empty, besides the face vector
Type can be void or a value, this way we can create many combinations from this
one mesh type.
This is not perfect, but helps to reduce a type explosion (imagine defining
every attribute combination as a new type).
It's still experimental, but this design has been working well for me so far.
This type is also heavily linked to GLVisualize, which means if you can
transform another meshtype to this type
chances are high that GLVisualize can display them.
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

# Creates a mesh from a file
# This function should really be defined in FileIO, but can't as it's ambigous with every damn constructor...
# Its nice, as you can simply do something like GLNormalMesh(file"mesh.obj")

typealias HMesh HomogenousMesh

#Type aliases

typealias Triangle{T} Face{3, T, 0}
typealias GLFace{Dim} Face{Dim, Cuint, -1} #offset is relative to julia, so -1 is 0-indexed
typealias GLTriangle  Face{3, Cuint, -1}
typealias GLQuad      Face{4, Cuint, -1}

typealias Cube{T}   HyperCube{3, T}
typealias Circle{T} HyperSphere{2, T}
typealias Sphere{T} HyperSphere{3, T}
call(::Type{Sphere}, x...) = HyperSphere(x...)
call(::Type{Circle}, x...) = HyperSphere(x...)

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

