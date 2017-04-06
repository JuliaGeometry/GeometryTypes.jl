# GeometryTypes

[![Build Status](https://travis-ci.org/JuliaGeometry/GeometryTypes.jl.svg?branch=master)](https://travis-ci.org/JuliaGeometry/GeometryTypes.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/m8ewjryjcxu1450m/branch/master?svg=true)](https://ci.appveyor.com/project/SimonDanisch/geometrytypes-jl/branch/master)
[![Coverage Status](https://coveralls.io/repos/JuliaGeometry/GeometryTypes.jl/badge.svg)](https://coveralls.io/r/JuliaGeometry/GeometryTypes.jl)

Geometry primitives and operations building up on FixedSizeArrays.

Documentation is available [here](./docs/build/).


Some of the types offered by GeometryTypes visualized with [GLVisualize](http://www.glvisualize.com/):

```Julia
HyperRectangle(Vec2f0(0), Vec2f0(100))
```

<img src="https://cloud.githubusercontent.com/assets/1010467/14317883/a0dc3014-fc0a-11e5-860b-ee7e15bc2f9b.png" width="132">

```Julia
HyperRectangle(Vec3f0(0), Vec3f0(1))
HyperCube(Vec3f0(0), 1f0)
```
<img src="https://cloud.githubusercontent.com/assets/1010467/14317856/80f4bd52-fc0a-11e5-986a-cac828585a21.png" width="132">

```Julia
HyperSphere(Point2f0(100), 100f0)
```
<img src="https://cloud.githubusercontent.com/assets/1010467/14317827/4d8633f6-fc0a-11e5-920e-caa7e5c7c3e7.png" width="132">

```Julia
HyperSphere(Point3f0(0), 1f0)
```
<img src="https://cloud.githubusercontent.com/assets/1010467/14317840/666c1e44-fc0a-11e5-8430-c214e6640690.png" width="132">


```Julia
Pyramid(Point3f0(0), 1f0, 1f0)
```
<img src="https://cloud.githubusercontent.com/assets/1010467/14317798/3742e350-fc0a-11e5-9c10-b46fde8d9b1b.png" width="132">

```Julia
load("cat.obj") # --> GLNormalMesh, via FileIO
```
<img src="https://cloud.githubusercontent.com/assets/1010467/14317773/1c4087f6-fc0a-11e5-95c5-97d4cd840c1a.png" width="132">


# Displaying primitives

To display geometry primitives, they need to be decomposable.
This can be done for any arbitrary primitive, by overloading the following interface:
```Julia
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
    faces = vec([Face{4, Int, 0}(
            sub2ind(resolution, i, j), sub2ind(resolution, i+1, j),
            sub2ind(resolution, i+1, j+1), sub2ind(resolution, i, j+1)
        ) for i=1:(w-1), j=1:(h-1)]
    )
    decompose(T, faces)
end
```
With these methods defined, this constructor will magically work:
```Julia
rect = SimpleRectangle(...)
mesh = GLNormalMesh(rect)
vertices(mesh) == decompose(Point3f0, rect)

faces(mesh) == decompose(GLTriangle, rect) # Face{3, UInt32, 0} == GLTriangle
normals(mesh) # automatically calculated from mesh
```
As you can see, the normals are automatically calculated only with the faces and points.
You can overwrite that behavior, by also defining decompose for the `Normal` type!
