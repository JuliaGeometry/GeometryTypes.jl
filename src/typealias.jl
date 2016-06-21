#Create typealiases like Mat4f0, Point2, Point2f0
for i=1:4
    for T=[:Point, :Vec]
        name 	= Symbol("$T$i")
        namef0 	= Symbol("$T$(i)f0")
        @eval begin
            typealias $name $T{$i}
            typealias $namef0 $T{$i, Float32}
            export $name
            export $namef0
        end
    end
    name   = Symbol("Mat$i")
    namef0 = Symbol("Mat$(i)f0")
    @eval begin
        typealias $name $Mat{$i,$i}
        typealias $namef0 $Mat{$i,$i, Float32}
        export $name
        export $namef0
    end
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

"""
An alias for a HyperSphere of dimension 3. i.e. Sphere{T} -> HyperSphere{3, T}
"""
typealias Sphere{T} HyperSphere{3, T}

typealias AbsoluteRectangle{T} HyperRectangle{2, T}

"""
AABB, or Axis Aligned Bounding Box, is an alias for a 3D HyperRectangle.
"""
typealias AABB{T} HyperRectangle{3, T}
@compat (::Type{AABB})(m...) = HyperRectangle(m...)

typealias HMesh HomogenousMesh

typealias UV{T} TextureCoordinate{2, T}
typealias UVW{T} TextureCoordinate{3, T}

"""
A `SimpleMesh` is an alias for a `HomogenousMesh` parameterized only by
vertex and face types.
"""
typealias SimpleMesh{VT, FT} HMesh{VT, FT, Void, Void, Void, Void, Void}
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

typealias NormalVertexcolorMesh{VT, FT, NT, CT} HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, Vector{CT}, Void, Void}
typealias GLNormalVertexcolorMesh NormalVertexcolorMesh{Float32, GLTriangle, Float32, RGBA{Float32}}

typealias NormalAttributeMesh{VT, FT, NT, AT, A_ID_T} HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, Void, AT, A_ID_T}
typealias GLNormalAttributeMesh NormalAttributeMesh{Float32, GLTriangle, Float32, Vector{RGBA{U8}}, Float32}

typealias NormalUVWMesh{VT, FT, NT, UVT} HMesh{Point{3, VT}, FT, Normal{3, NT}, UVW{UVT}, Void, Void, Void}
typealias GLNormalUVWMesh NormalUVWMesh{Float32, GLTriangle, Float32, Float32}

typealias NormalUVMesh{VT, FT, NT, UVT} HMesh{Point{3, VT}, FT, Normal{3, NT}, UV{UVT}, Void, Void, Void}
typealias GLNormalUVMesh NormalUVMesh{Float32, GLTriangle, Float32, Float32}
