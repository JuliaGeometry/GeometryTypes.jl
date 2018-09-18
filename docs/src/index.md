# GeometryTypes

[![Build Status](https://travis-ci.org/JuliaGeometry/GeometryTypes.jl.svg?branch=master)](https://travis-ci.org/JuliaGeometry/GeometryTypes.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/m8ewjryjcxu1450m/branch/master?svg=true)](https://ci.appveyor.com/project/SimonDanisch/geometrytypes-jl/branch/master)
[![Coverage Status](https://coveralls.io/repos/JuliaGeometry/GeometryTypes.jl/badge.svg)](https://coveralls.io/r/JuliaGeometry/GeometryTypes.jl)

Geometry primitives and operations building up on FixedSizeArrays.

Some of the types offered by GeometryTypes visualized with [GLVisualize](https://github.com/JuliaGL/GLVisualize.jl):

```julia
HyperRectangle(Vec2f0(0), Vec2f0(100))
```

![HyperRectangle1](screenshots/a0dc3014-fc0a-11e5-860b-ee7e15bc2f9b.png)

```julia
HyperRectangle(Vec3f0(0), Vec3f0(1))
HyperCube(Vec3f0(0), 1f0)
```

![HyperRectangle2](screenshots/80f4bd52-fc0a-11e5-986a-cac828585a21.png)

```julia
HyperSphere(Point2f0(100), 100f0)
```

![HyperSphere1](screenshots/4d8633f6-fc0a-11e5-920e-caa7e5c7c3e7.png)

```julia
HyperSphere(Point3f0(0), 1f0)
```

![HyperSphere2](screenshots/666c1e44-fc0a-11e5-8430-c214e6640690.png)

```julia
Pyramid(Point3f0(0), 1f0, 1f0)
```

![Pyramid](screenshots/3742e350-fc0a-11e5-9c10-b46fde8d9b1b.png)

```julia
load("cat.obj") # --> GLNormalMesh, via FileIO
```

![GLNormalMesh](screenshots/1c4087f6-fc0a-11e5-95c5-97d4cd840c1a.png)

## Displaying primitives

To display geometry primitives, they need to be decomposable.
This can be done for any arbitrary primitive, by overloading the following interface:

```julia
# Lets take SimpleRectangle as an example:
# Minimal set of decomposable attributes to build up a triangle mesh
isdecomposable{T<:Point, HR<:SimpleRectangle}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:Face, HR<:SimpleRectangle}(::Type{T}, ::Type{HR}) = true

# Example implementation of decompose for points
function decompose{PT}(P::Type{Point{3, PT}}, r::SimpleRectangle, resolution=(2,2))
    w,h = resolution
    vec(P[(x,y,0) for x=linspace(r.x, r.x+r.w, w), y=linspace(r.y, r.y+r.h, h)])
end

function decompose{T<:Face}(::Type{T}, r::SimpleRectangle, resolution=(2,2))
    w,h = resolution
    Idx = LinearIndices(resolution)
    faces = vec([Face{4, Int}(
            Idx[i, j], Idx[i+1, j],
            Idx[i+1, j+1], Idx[i, j+1]
        ) for i=1:(w-1), j=1:(h-1)]
    )
    decompose(T, faces)
end
```

With these methods defined, this constructor will magically work:

```julia
rect = SimpleRectangle(...)
mesh = GLNormalMesh(rect)
vertices(mesh) == decompose(Point3f0, rect)

faces(mesh) == decompose(GLTriangle, rect) # GLFace{3} == GLTriangle
normals(mesh) # automatically calculated from mesh
```

As you can see, the normals are automatically calculated only with the faces and points.
You can overwrite that behavior, by also defining decompose for the `Normal` type!
