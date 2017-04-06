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
        @compat const $name{T} = $Mat{$i,$i, T, $(i*i)}
        const $namef0 = $name{Float32}
        export $name
        export $namef0
    end
end

#Type aliases
@compat const U8 = FixedPointNumbers.Normed{UInt8, 8}

"""
An alias for a one-simplex, corresponding to LineSegment{T} -> Simplex{2,T}.
"""
@compat const LineSegment{T} = Simplex{2,T}

@compat const ZeroIndex{T} = OffsetInteger{1, T}
@compat const OneIndex{T} = OffsetInteger{0, T}
const GLIndex = ZeroIndex{Cuint}

@compat const Triangle{T} = Face{3, T}
@compat const GLFace{Dim} = Face{Dim, GLIndex} #offset is relative to julia, so -1 is 0-indexed
@compat const GLTriangle = Face{3, GLIndex}
const GLQuad = Face{4, GLIndex}

@compat const Cube{T} = HyperCube{3, T}

"""
An alias for a HyperSphere of dimension 2. i.e. Circle{T} -> HyperSphere{2, T}
"""
@compat const Circle{T} = HyperSphere{2, T}

"""
An alias for a HyperSphere of dimension 3. i.e. Sphere{T} -> HyperSphere{3, T}
"""
@compat const Sphere{T} = HyperSphere{3, T}

@compat const AbsoluteRectangle{T} = HyperRectangle{2, T}

"""
AABB, or Axis Aligned Bounding Box, is an alias for a 3D HyperRectangle.
"""
@compat const AABB{T} = HyperRectangle{3, T}
(::Type{AABB})(m...) = HyperRectangle(m...)

@compat const HMesh = HomogenousMesh

@compat const UV{T} = TextureCoordinate{2, T}
@compat const UVW{T} = TextureCoordinate{3, T}

"""
A `SimpleMesh` is an alias for a `HomogenousMesh` parameterized only by
vertex and face types.
"""
@compat const SimpleMesh{VT, FT} = HMesh{VT, FT, Void, Void, Void, Void, Void}
@compat const PlainMesh{VT, FT} = HMesh{Point{3, VT}, FT, Void, Void, Void, Void, Void}
@compat const GLPlainMesh = PlainMesh{Float32, GLTriangle}

@compat const Mesh2D{VT, FT} = HMesh{Point{2, VT}, FT, Void, Void, Void, Void, Void}
@compat const GLMesh2D = Mesh2D{Float32, GLTriangle}

@compat const UVMesh{VT, FT, UVT} = HMesh{Point{3, VT}, FT, Void, UV{UVT}, Void, Void, Void}
@compat const GLUVMesh = UVMesh{Float32, GLTriangle, Float32}

@compat const UVWMesh{VT, FT, UVT} = HMesh{Point{3, VT}, FT, Void, UVW{UVT}, Void, Void, Void}
@compat const GLUVWMesh = UVWMesh{Float32, GLTriangle, Float32}

@compat const NormalMesh{VT, FT, NT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, Void, Void, Void}
@compat const GLNormalMesh = NormalMesh{Float32, GLTriangle, Float32}

@compat const UVMesh2D{VT, FT, UVT} = HMesh{Point{2, VT}, FT, Void, UV{UVT}, Void, Void, Void}
@compat const GLUVMesh2D = UVMesh2D{Float32, GLTriangle, Float32}

@compat const NormalColorMesh{VT, FT, NT, CT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, CT, Void, Void}
@compat const GLNormalColorMesh = NormalColorMesh{Float32, GLTriangle, Float32, RGBA{Float32}}

@compat const NormalVertexcolorMesh{VT, FT, NT, CT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, Vector{CT}, Void, Void}
@compat const GLNormalVertexcolorMesh = NormalVertexcolorMesh{Float32, GLTriangle, Float32, RGBA{Float32}}

@compat const NormalAttributeMesh{VT, FT, NT, AT, A_ID_T} = HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, Void, AT, A_ID_T}
@compat const GLNormalAttributeMesh = NormalAttributeMesh{Float32, GLTriangle, Float32, Vector{RGBA{U8}}, Float32}

@compat const NormalUVWMesh{VT, FT, NT, UVT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, UVW{UVT}, Void, Void, Void}
@compat const GLNormalUVWMesh = NormalUVWMesh{Float32, GLTriangle, Float32, Float32}

@compat const NormalUVMesh{VT, FT, NT, UVT} = HMesh{Point{3, VT}, FT, Normal{3, NT}, UV{UVT}, Void, Void, Void}
@compat const GLNormalUVMesh = NormalUVMesh{Float32, GLTriangle, Float32, Float32}
