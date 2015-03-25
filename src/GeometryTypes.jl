module GeometryTypes

using FixedSizeArrays

export row
export column

include("types.jl")

# Immutable Vector type
export Vector2
export Vector3
export Vector4

#Mutable Vector type
export MVector2
export MVector3
export MVector4

# Immutable Point type
export Point2
export Point3
export Point4

#Mutable Point type
export MPoint2
export MPoint3
export MPoint4

# Immutable Normal type
export Normal2
export Normal3
export Normal4

#Mutable Normal type
export MNormal2
export MNormal3
export MNormal4

#Texture Coordinate Types
export UV
export UVW

export MUV
export MUVW

#Face Types
export Face3
export Face4
export Face5
export Face6
export Face7
export Face8

export MFace3
export MFace4
export MFace5
export MFace6
export MFace7
export MFace8

typealias Triangle{T} Face3{T}
export Triangle
typealias Quad{T} Face3{T}
export Quad

# Some primitives
export Cube
export Circle
export Sphere
export Rectangle

export MCube
export MCircle
export MSphere
export MRectangle




export Matrix1x2
export Matrix1x3
export Matrix1x4

export Matrix2x1
export Matrix2x2
export Matrix2x3
export Matrix2x4

export Matrix3x1
export Matrix3x2
export Matrix3x3
export Matrix3x4

export Matrix4x1
export Matrix4x2
export Matrix4x3
export Matrix4x4

#Mutable Matrices
export MMatrix1x1
export MMatrix1x2
export MMatrix1x3
export MMatrix1x4

export MMatrix2x1
export MMatrix2x2
export MMatrix2x3
export MMatrix2x4

export MMatrix3x1
export MMatrix3x2
export MMatrix3x3
export MMatrix3x4

export MMatrix4x1
export MMatrix4x2
export MMatrix4x3
export MMatrix4x4

end # module

