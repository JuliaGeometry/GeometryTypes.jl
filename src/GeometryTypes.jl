VERSION >= v"0.4.0-dev+6521" && __precompile__(true)
module GeometryTypes

using FixedSizeArrays
using ColorTypes

using Compat

import Base: ==, *

import Base: merge
import Base: convert
import Base: call

import Base: getindex
import Base: setindex!

import Base: show
import Base: unique
import Base: merge
import Base: length

import Base: maximum
import Base: minimum
import Base: isequal
import Base: isless

import Base: contains
import Base: in
import Base: split
import Base: union
import Base: diff
import Base: intersect

export unit
export row
export column
export normalize
export width
export height

include("types.jl")

export HyperRectangle

export Vec
export Point
export TextureCoordinate
export Normal
export Face
export Mat

# Some primitives
export GeometryPrimitive

export Cube
export Circle                   # Simple circle object

export Sphere
export Rectangle                # Simple rectangle object
export Quad
export AABB                		# bounding slab (Axis Aligned Bounding Box)

export Pyramid

export Mat


include("algorithms.jl")
export normals
export area
export xwidth
export yheight
export isinside
export isoutside
include("faces.jl")

include("HyperRectangles/HyperRectangles.jl")


include("meshtypes.jl")
include("primitives.jl")

export UV
export UVW

export Mesh
export HomogenousMesh
export HMesh
export NormalMesh
export UVWMesh
export UVMesh2D
export UVMesh
export PlainMesh
export Mesh2D
export NormalAttributeMesh
export NormalColorMesh
export NormalUVWMesh
export NormalUVMesh

export GLMesh2D
export GLNormalMesh
export GLUVWMesh
export GLUVMesh2D
export GLUVMesh
export GLPlainMesh
export GLNormalAttributeMesh
export GLNormalColorMesh
export GLNormalUVWMesh
export GLNormalUVMesh

export vertextype
export facetype
export normaltype
export texturecoordinatetype
export colortype


export attributes
export attributes_noVF

export normals

end # module
