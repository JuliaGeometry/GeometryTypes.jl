var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "GeometryTypes",
    "title": "GeometryTypes",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#GeometryTypes-1",
    "page": "GeometryTypes",
    "title": "GeometryTypes",
    "category": "section",
    "text": "(Image: Build Status) (Image: Build status) (Image: Coverage Status)Geometry primitives and operations building up on FixedSizeArrays.Some of the types offered by GeometryTypes visualized with GLVisualize:HyperRectangle(Vec2f0(0), Vec2f0(100))(Image: HyperRectangle1)HyperRectangle(Vec3f0(0), Vec3f0(1))\nHyperCube(Vec3f0(0), 1f0)(Image: HyperRectangle2)HyperSphere(Point2f0(100), 100f0)(Image: HyperSphere1)HyperSphere(Point3f0(0), 1f0)(Image: HyperSphere2)Pyramid(Point3f0(0), 1f0, 1f0)(Image: Pyramid)load(\"cat.obj\") # --> GLNormalMesh, via FileIO(Image: GLNormalMesh)"
},

{
    "location": "index.html#Displaying-primitives-1",
    "page": "GeometryTypes",
    "title": "Displaying primitives",
    "category": "section",
    "text": "To display geometry primitives, they need to be decomposable. This can be done for any arbitrary primitive, by overloading the following interface:# Lets take SimpleRectangle as an example:\n# Minimal set of decomposable attributes to build up a triangle mesh\nisdecomposable{T<:Point, HR<:SimpleRectangle}(::Type{T}, ::Type{HR}) = true\nisdecomposable{T<:Face, HR<:SimpleRectangle}(::Type{T}, ::Type{HR}) = true\n\n# Example implementation of decompose for points\nfunction decompose{PT}(P::Type{Point{3, PT}}, r::SimpleRectangle, resolution=(2,2))\n    w,h = resolution\n    vec(P[(x,y,0) for x=linspace(r.x, r.x+r.w, w), y=linspace(r.y, r.y+r.h, h)])\nend\n\nfunction decompose{T<:Face}(::Type{T}, r::SimpleRectangle, resolution=(2,2))\n    w,h = resolution\n    Idx = LinearIndices(resolution)\n    faces = vec([Face{4, Int}(\n            Idx[i, j], Idx[i+1, j],\n            Idx[i+1, j+1], Idx[i, j+1]\n        ) for i=1:(w-1), j=1:(h-1)]\n    )\n    decompose(T, faces)\nendWith these methods defined, this constructor will magically work:rect = SimpleRectangle(...)\nmesh = GLNormalMesh(rect)\nvertices(mesh) == decompose(Point3f0, rect)\n\nfaces(mesh) == decompose(GLTriangle, rect) # GLFace{3} == GLTriangle\nnormals(mesh) # automatically calculated from meshAs you can see, the normals are automatically calculated only with the faces and points. You can overwrite that behavior, by also defining decompose for the Normal type!"
},

{
    "location": "operations.html#",
    "page": "GeometryTypes - Operations",
    "title": "GeometryTypes - Operations",
    "category": "page",
    "text": ""
},

{
    "location": "operations.html#GeometryTypes-Operations-1",
    "page": "GeometryTypes - Operations",
    "title": "GeometryTypes - Operations",
    "category": "section",
    "text": ""
},

{
    "location": "operations.html#GeometryTypes.slice",
    "page": "GeometryTypes - Operations",
    "title": "GeometryTypes.slice",
    "category": "function",
    "text": "Slice an AbstractMesh at the specified Z axis value. Returns a Vector of LineSegments generated from the faces at the specified heights. Note: This will not slice in-plane faces.\n\n\n\n\n\n"
},

{
    "location": "operations.html#Slicing-1",
    "page": "GeometryTypes - Operations",
    "title": "Slicing",
    "category": "section",
    "text": "slice"
},

{
    "location": "operations.html#Base.union",
    "page": "GeometryTypes - Operations",
    "title": "Base.union",
    "category": "function",
    "text": "Perform a union between two HyperRectangles.\n\n\n\n\n\n"
},

{
    "location": "operations.html#Base.diff",
    "page": "GeometryTypes - Operations",
    "title": "Base.diff",
    "category": "function",
    "text": "Perform a difference between two HyperRectangles.\n\n\n\n\n\n"
},

{
    "location": "operations.html#Base.intersect",
    "page": "GeometryTypes - Operations",
    "title": "Base.intersect",
    "category": "function",
    "text": "Perform a intersection between two HyperRectangles.\n\n\n\n\n\n"
},

{
    "location": "operations.html#Set-Operations-1",
    "page": "GeometryTypes - Operations",
    "title": "Set Operations",
    "category": "section",
    "text": "union\ndiff\nintersect"
},

{
    "location": "operations.html#GeometryTypes.decompose",
    "page": "GeometryTypes - Operations",
    "title": "GeometryTypes.decompose",
    "category": "function",
    "text": "Allow to call decompose with unspecified vector type and infer types from primitive.\n\n\n\n\n\ndecompose{N, FT1, FT2, O1, O2}(::Type{Face{3, FT1, O1}},\n                               f::Face{N, FT2, O2})\n\nTriangulate an N-Face into a tuple of triangular faces.\n\n\n\n\n\ndecompose{N, FT1, FT2, O1, O2}(::Type{Face{2, FT1, O1}},\n                               f::Face{N, FT2, O2})\n\nExtract all line segments in a Face.\n\n\n\n\n\nDecompose an N-Simplex into a tuple of Simplex{3}\n\n\n\n\n\nDecompose an N-Simplex into tuple of Simplex{2}\n\n\n\n\n\nDecompose an N-Simplex into a tuple of Simplex{1}\n\n\n\n\n\nGet decompose a HyperRectangle into points.\n\n\n\n\n\nGet decompose a HyperRectangle into Texture Coordinates.\n\n\n\n\n\nGet decompose a HyperRectangle into faces.\n\n\n\n\n\n"
},

{
    "location": "operations.html#Decompositions-1",
    "page": "GeometryTypes - Operations",
    "title": "Decompositions",
    "category": "section",
    "text": "decompose"
},

{
    "location": "types.html#",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes - Types",
    "category": "page",
    "text": ""
},

{
    "location": "types.html#GeometryTypes-Types-1",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes - Types",
    "category": "section",
    "text": ""
},

{
    "location": "types.html#GeometryTypes.HyperRectangle",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.HyperRectangle",
    "category": "type",
    "text": "A HyperRectangle is a generalization of a rectangle into N-dimensions. Formally it is the cartesian product of intervals, which is represented by the origin and width fields, whose indices correspond to each of the N axes.\n\n\n\n\n\n"
},

{
    "location": "types.html#GeometryTypes.HyperSphere",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.HyperSphere",
    "category": "type",
    "text": "A HyperSphere is a generalization of a sphere into N-dimensions. A center and radius, r, must be specified.\n\n\n\n\n\n"
},

{
    "location": "types.html#Hyper-Geometry-1",
    "page": "GeometryTypes - Types",
    "title": "Hyper Geometry",
    "category": "section",
    "text": "HyperRectangleHyperSphere"
},

{
    "location": "types.html#GeometryTypes.Simplex",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.Simplex",
    "category": "type",
    "text": "A Simplex is a generalization of an N-dimensional tetrahedra and can be thought of as a minimal convex set containing the specified points.\n\nA 0-simplex is a point.\nA 1-simplex is a line segment.\nA 2-simplex is a triangle.\nA 3-simplex is a tetrahedron.\n\nNote that this datatype is offset by one compared to the traditional mathematical terminology. So a one-simplex is represented as Simplex{2,T}. This is for a simpler implementation.\n\nIt applies to infinite dimensions. The structure of this type is designed to allow embedding in higher-order spaces by parameterizing on T.\n\n\n\n\n\n"
},

{
    "location": "types.html#GeometryTypes.LineSegment",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.LineSegment",
    "category": "type",
    "text": "An alias for a one-simplex, corresponding to LineSegment{T} -> Simplex{2,T}.\n\n\n\n\n\n"
},

{
    "location": "types.html#GeometryTypes.Circle",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.Circle",
    "category": "type",
    "text": "An alias for a HyperSphere of dimension 2. i.e. Circle{T} -> HyperSphere{2, T}\n\n\n\n\n\n"
},

{
    "location": "types.html#GeometryTypes.Sphere",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.Sphere",
    "category": "type",
    "text": "An alias for a HyperSphere of dimension 3. i.e. Sphere{T} -> HyperSphere{3, T}\n\n\n\n\n\n"
},

{
    "location": "types.html#Primitives-1",
    "page": "GeometryTypes - Types",
    "title": "Primitives",
    "category": "section",
    "text": "SimplexLineSegmentCircleSphere"
},

{
    "location": "types.html#GeometryTypes.HomogenousMesh",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.HomogenousMesh",
    "category": "type",
    "text": "The HomogenousMesh type describes a polygonal mesh that is useful for computation on the CPU or on the GPU. All vectors must have the same length or must be empty, besides the face vector Type can be Void or a value, this way we can create many combinations from this one mesh type. This is not perfect, but helps to reduce a type explosion (imagine defining every attribute combination as a new type).\n\n\n\n\n\n"
},

{
    "location": "types.html#Meshes-1",
    "page": "GeometryTypes - Types",
    "title": "Meshes",
    "category": "section",
    "text": "HomogenousMesh"
},

{
    "location": "types.html#GeometryTypes.Face",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.Face",
    "category": "type",
    "text": "A Face is typically used when constructing subtypes of AbstractMesh where the Face should not reproduce the vertices, but rather index into them. Face is parameterized by:\n\nN - The number of vertices in the face.\nT - The type of the indices in the face, a subtype of Integer.\n\n\n\n\n\n"
},

{
    "location": "types.html#Faces-1",
    "page": "GeometryTypes - Types",
    "title": "Faces",
    "category": "section",
    "text": "Face"
},

{
    "location": "types.html#GeometryTypes.SignedDistanceField",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.SignedDistanceField",
    "category": "type",
    "text": "A SignedDistanceField is a uniform sampling of an implicit function. The bounds field corresponds to the sampling space intervals on each axis. The data field represents the value at each point whose exact location can be rationalized from bounds. The type is parameterized by:\n\nN - The dimensionality of the sampling space.\nSpaceT - the type of the space where we will uniformly sample.\nFieldT - the type resulting from evaluation of the implicit function.\n\nNote that decoupling the space and field types is useful since geometry can be formulated with integers and distances can be measured with floating points.\n\n\n\n\n\n"
},

{
    "location": "types.html#DistanceFields-1",
    "page": "GeometryTypes - Types",
    "title": "DistanceFields",
    "category": "section",
    "text": "SignedDistanceField"
},

{
    "location": "types.html#GeometryTypes.AbstractSimplex",
    "page": "GeometryTypes - Types",
    "title": "GeometryTypes.AbstractSimplex",
    "category": "type",
    "text": "Abstract to classify Simplices. The convention for N starts at 1, which means a Simplex has 1 point. A 2-simplex has 2 points, and so forth. This convention is not the same as most mathematical texts.\n\n\n\n\n\n"
},

{
    "location": "types.html#Abstract-Types-1",
    "page": "GeometryTypes - Types",
    "title": "Abstract Types",
    "category": "section",
    "text": "GeometryPrimitiveAbstractSimplexAbstractMeshAbstractDistanceField"
},

]}
