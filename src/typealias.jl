#Create constes like Mat4f0, Point2, Point2f0
for i=1:4
    for T=[:Point, :Vec]
        name = Symbol("$T$i")
        namef0 = Symbol("$T$(i)f0")
        @eval begin
            const $name = $T{$i}
            const $namef0 = $T{$i, Float32}
            export $name
            export $namef0
        end
    end
    name   = Symbol("Mat$i")
    namef0 = Symbol("Mat$(i)f0")
    @eval begin
        const $name{T} = $Mat{$i,$i, T, $(i*i)}
        const $namef0 = $name{Float32}
        export $name
        export $namef0
    end
end

#Type aliases
const U8 = FixedPointNumbers.Normed{UInt8, 8}

"""
An alias for a one-simplex, corresponding to LineSegment{T} -> Simplex{2,T}.
"""
const LineSegment{T} = Simplex{2,T}

const ZeroIndex{T <: Integer} = OffsetInteger{-1, T}
const OneIndex{T <: Integer} = OffsetInteger{0, T}
const GLIndex = ZeroIndex{Cuint}

const Triangle{T} = Face{3, T}
const GLFace{Dim} = Face{Dim, GLIndex} #offset is relative to julia, so -1 is 0-indexed
const GLTriangle = Face{3, GLIndex}
const GLQuad = Face{4, GLIndex}

const Cube{T} = HyperCube{3, T}

"""
An alias for a HyperSphere of dimension 2. i.e. Circle{T} -> HyperSphere{2, T}
"""
const Circle{T} = HyperSphere{2, T}

"""
An alias for a HyperSphere of dimension 3. i.e. Sphere{T} -> HyperSphere{3, T}
"""
const Sphere{T} = HyperSphere{3, T}

const AbsoluteRectangle{T} = HyperRectangle{2, T}

"""
AABB, or Axis Aligned Bounding Box, is an alias for a 3D HyperRectangle.
"""
const AABB{T} = HyperRectangle{3, T}
AABB(m...) = HyperRectangle(m...)

const HMesh = HomogenousMesh

"""
A `Cylinder2` or `Cylinder3` is a 2D/3D cylinder defined by its origin point,
its extremity and a radius. `origin`, `extremity` and `r`, must be specified.
"""
const Cylinder2{T} = Cylinder{2, T}
const Cylinder3{T} = Cylinder{3, T}



const UV{T} = TextureCoordinate{2, T}
const UVW{T} = TextureCoordinate{3, T}

"""
A `SimpleMesh` is an alias for a `HomogenousMesh` parameterized only by
vertex and face types.
"""
const SimpleMesh{VT, FT} = HMesh{VT, FT, Nothing, Nothing, Nothing, Nothing, Nothing}
const PlainMesh{VT, FT} = HMesh{Point{3, VT}, FT, Nothing, Nothing, Nothing, Nothing, Nothing}
const GLPlainMesh = PlainMesh{Float32, GLTriangle}

const Mesh2D{VT, FT} = HMesh{Point{2, VT}, FT, Nothing, Nothing, Nothing, Nothing, Nothing}
const GLMesh2D = Mesh2D{Float32, GLTriangle}

const UVMesh{VT, FT, UVT} = HMesh{Point{3, VT}, FT, Nothing, UV{UVT}, Nothing, Nothing, Nothing}
const GLUVMesh = UVMesh{Float32, GLTriangle, Float32}

const UVWMesh{VT, FT, UVT} = HMesh{Point{3, VT}, FT, Nothing, UVW{UVT}, Nothing, Nothing, Nothing}
const GLUVWMesh = UVWMesh{Float32, GLTriangle, Float32}

const NormalMesh{VT, FT, NT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, Nothing, Nothing, Nothing, Nothing}
const GLNormalMesh = NormalMesh{Float32, GLTriangle, Float32}

const UVMesh2D{VT, FT, UVT} = HMesh{Point{2, VT}, FT, Nothing, UV{UVT}, Nothing, Nothing, Nothing}
const GLUVMesh2D = UVMesh2D{Float32, GLTriangle, Float32}

const NormalColorMesh{VT, FT, NT, CT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, Nothing, CT, Nothing, Nothing}
const GLNormalColorMesh = NormalColorMesh{Float32, GLTriangle, Float32, RGBA{Float32}}

const NormalVertexcolorMesh{VT, FT, NT, CT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, Nothing, Vector{CT}, Nothing, Nothing}
const GLNormalVertexcolorMesh = NormalVertexcolorMesh{Float32, GLTriangle, Float32, RGBA{Float32}}

const NormalAttributeMesh{VT, FT, NT, AT, A_ID_T} = HMesh{Point{3, VT}, FT, Normal{3, NT}, Nothing, Nothing, AT, A_ID_T}
const GLNormalAttributeMesh = NormalAttributeMesh{Float32, GLTriangle, Float32, Vector{RGBA{U8}}, Float32}

const NormalUVWMesh{VT, FT, NT, UVT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, UVW{UVT}, Nothing, Nothing, Nothing}
const GLNormalUVWMesh = NormalUVWMesh{Float32, GLTriangle, Float32, Float32}

const NormalUVMesh{VT, FT, NT, UVT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, UV{UVT}, Nothing, Nothing, Nothing}
const GLNormalUVMesh = NormalUVMesh{Float32, GLTriangle, Float32, Float32}
