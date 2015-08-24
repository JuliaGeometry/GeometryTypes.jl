using GeometryTypes, ColorTypes
typealias Vec3f0 Vec{3, Float32}
baselen = 0.4f0
dirlen  = 2f0
axis    = [
    (Cube{Float32}(Vec3f0(baselen), Vec3f0(dirlen, baselen, baselen)), RGBA(1f0,0f0,0f0,1f0)),
    (Cube{Float32}(Vec3f0(baselen), Vec3f0(baselen, dirlen, baselen)), RGBA(0f0,1f0,0f0,1f0)),
    (Cube{Float32}(Vec3f0(baselen), Vec3f0(baselen, baselen, dirlen)), RGBA(0f0,0f0,1f0,1f0))
]

axis = map(GLNormalMesh, axis)
axis = merge(axis)
