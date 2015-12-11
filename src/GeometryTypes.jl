VERSION >= v"0.4.0-dev+6521" && __precompile__(true)
module GeometryTypes

using FixedSizeArrays
using ColorTypes

import Base: ==,
             *,
             call,
             contains,
             convert,
             diff,
             getindex,
             in,
             intersect,
             isequal,
             isless,
             length,
             maximum,
             merge,
             merge,
             minimum,
             setindex!,
             show,
             split,
             union,
             unique


include("types.jl")
include("typealias.jl")
include("simplices.jl")
include("algorithms.jl")
include("faces.jl")
include("hyperrectangles.jl")
include("relations.jl")
include("operations.jl")
include("meshtypes.jl")
include("primitives.jl")
include("distancefields.jl")
include("setops.jl")
include("display.jl")
include("slice.jl")
include("decompose.jl")
include("deprecated.jl")

export AABB,
       AbsoluteRectangle,
       AbstractMesh,
       AbstractSimplex,
       AbstractDistanceField,
       Circle,
       centered,
       Cube,
       decompose,
       Face,
       GLFace,
       GLMesh2D,
       GLNormalAttributeMesh,
       GLNormalColorMesh,
       GLNormalMesh,
       GLNormalUVMesh,
       GLNormalUVWMesh,
       GLPlainMesh,
       GLQuad,
       GLTriangle,
       GLUVMesh,
       GLUVMesh2D,
       GLUVWMesh,
       GeometryPrimitive,
       HMesh,
       HomogenousMesh,
       HyperRectangle,
       HyperCube,
       HyperSphere,
       LineSegment,
       Mat,
       Mesh2D,
       Normal,
       NormalAttributeMesh,
       NormalColorMesh,
       NormalMesh,
       NormalUVMesh,
       NormalUVWMesh,
       Particle,
       PlainMesh,
       Point,
       Pyramid,
       Quad,
       Rectangle,
       SignedDistanceField,
       SimpleRectangle,
       Simplex,
       Sphere,
       TextureCoordinate,
       Triangle,
       UV,
       UVMesh,
       UVMesh2D,
       UVW,
       UVWMesh,
       Vec,
       area,
       attributes,
       attributes_noVF,
       before,
       colors,
       colortype,
       column,
       during,
       faces,
       facetype,
       finishes,
       hascolors,
       hasfaces,
       hasnormals,
       hastexturecoordinates,
       hasvertices,
       height,
       isinside,
       isoutside,
       max_dist_dim,
       max_euclidean,
       max_euclideansq,
       meets,
       min_dist_dim,
       min_euclidean,
       min_euclideansq,
       minmax_dist_dim,
       minmax_euclidean,
       minmax_euclideansq,
       normalize,
       normals,
       normaltype,
       overlaps,
       points,
       row,
       setindex,
       starts,
       texturecoordinates,
       texturecoordinatetype,
       triangulate,
       unit,
       update,
       vertextype,
       vertices,
       width,
       xwidth,
       yheight

end # module
