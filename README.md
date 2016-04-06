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
