using GeometryTypes, FixedSizeArrays, Quaternions
using Base.Test




typealias Vec2d Vector2{Float64}
typealias Vec3d Vector3{Float64}
typealias Vec4d Vector4{Float64}
typealias Vec3f Vector3{Float32}

v1 = Vec3d(1.0,2.0,3.0)
v2 = Vec3d(6.0,5.0,4.0)

# indexing
@assert v1[1] == 1.0
@assert v1[2] == 2.0
@assert v1[3] == 3.0
@assert try v1[-1]; false; catch e; isa(e,BoundsError); end
@assert try v1[0];  false; catch e; isa(e,BoundsError); end
@assert try v1[4];  false; catch e; isa(e,BoundsError); end

# negation
@assert -v1 == Vec3d(-1.0,-2.0,-3.0)
@assert isa(-v1,Vec3d)

# addition
@assert v1+v2 == Vec3d(7.0,7.0,7.0)

# subtraction
@assert v2-v1 == Vec3d(5.0,3.0,1.0)

# multiplication
@assert v1.*v2 == Vec3d(6.0,10.0,12.0)

# division
@assert v1 ./ v1 == Vec3d(1.0,1.0,1.0)

# scalar operations
@assert 1.0 + v1 == Vec3d(2.0,3.0,4.0)
@assert 1.0 .+ v1 == Vec3d(2.0,3.0,4.0)
@assert v1 + 1.0 == Vec3d(2.0,3.0,4.0)
@assert v1 .+ 1.0 == Vec3d(2.0,3.0,4.0)
@assert 1 + v1 == Vec3d(2.0,3.0,4.0)
@assert 1 .+ v1 == Vec3d(2.0,3.0,4.0)
@assert v1 + 1 == Vec3d(2.0,3.0,4.0)
@assert v1 .+ 1 == Vec3d(2.0,3.0,4.0)

@assert v1 - 1.0 == Vec3d(0.0,1.0,2.0)
@assert v1 .- 1.0 == Vec3d(0.0,1.0,2.0)
@assert 1.0 - v1 == Vec3d(0.0,-1.0,-2.0)
@assert 1.0 .- v1 == Vec3d(0.0,-1.0,-2.0)
@assert v1 - 1 == Vec3d(0.0,1.0,2.0)
@assert v1 .- 1 == Vec3d(0.0,1.0,2.0)
@assert 1 - v1 == Vec3d(0.0,-1.0,-2.0)
@assert 1 .- v1 == Vec3d(0.0,-1.0,-2.0)

@assert 2.0 * v1 == Vec3d(2.0,4.0,6.0)
@assert 2.0 .* v1 == Vec3d(2.0,4.0,6.0)
@assert v1 * 2.0 == Vec3d(2.0,4.0,6.0)
@assert v1 .* 2.0 == Vec3d(2.0,4.0,6.0)
@assert 2 * v1 == Vec3d(2.0,4.0,6.0)
@assert 2 .* v1 == Vec3d(2.0,4.0,6.0)
@assert v1 * 2 == Vec3d(2.0,4.0,6.0)
@assert v1 .* 2 == Vec3d(2.0,4.0,6.0)

@assert v1 / 2.0 == Vec3d(0.5,1.0,1.5)
@assert v1 ./ 2.0 == Vec3d(0.5,1.0,1.5)
@assert v1 / 2 == Vec3d(0.5,1.0,1.5)
@assert v1 ./ 2 == Vec3d(0.5,1.0,1.5)

@assert 12.0 ./ v1 == Vec3d(12.0,6.0,4.0)
@assert 12 ./ v1 == Vec3d(12.0,6.0,4.0)

@assert v1.^2 == Vec3d(1.0,4.0,9.0)
@assert v1.^2.0 == Vec3d(1.0,4.0,9.0)
@assert 2.0.^v1 == Vec3d(2.0,4.0,8.0)
@assert 2.^v1 == Vec3d(2.0,4.0,8.0)

# vector norm
@assert norm(Vec3d(1.0,2.0,2.0)) == 3.0

# cross product
@assert cross(v1,v2) == Vec3d(-7.0,14.0,-7.0)
@assert isa(cross(v1,v2),Vec3d)


# type conversion
@assert isa(convert(Vec3f,v1), Vec3f)

@assert isa(convert(Vector{Float64}, v1), Vector{Float64})
@assert convert(Vector{Float64}, v1) == [1.0,2.0,3.0]


# matrix operations

#typealias Mat1d Matrix1x1{Float64}
typealias Mat2d Matrix2x2{Float64}
typealias Mat3d Matrix3x3{Float64}
typealias Mat4d Matrix4x4{Float64}

@assert zero(Mat2d) == Mat2d(0.0,0.0,0.0,0.0)

v = Vec4d(1.0,2.0,3.0,4.0)
r = row(v)
c = column(v)

#@show prod(Vector1(0))
@show a = c*r
@show b=Mat4d(1.0,2.0,3.0,4.0,
             2.0,4.0,6.0,8.0,
             3.0,6.0,9.0,12.0,
             4.0,8.0,12.0,16.0)

@assert a==b
#@assert r*c == Matrix1x1(30.0)
#@assert r' == c
#@assert c' == r
#@assert row(r,1) == v
#@assert column(c,1) == v
#@assert row(r+c',1) == 2*v
@assert sum(r) == sum(v)
@assert prod(c) == prod(v)
@show eye(Mat3d)
@assert eye(Mat3d) == Mat3d(1.0,0.0,0.0,
							0.0,1.0,0.0,
							0.0,0.0,1.0)
#@assert v*eye(Mat4d)*v == 30.0
@assert -r == -1.0*r
#@assert diag(diagm(v)) == v

# type conversion
#@assert isa(convert(Matrix1x4{Float32},r),Matrix1x4{Float32})
jm = rand(4,4)
im = convert(Matrix4x4, jm)
#im = Matrix4x4(jm)
println(im)
@assert isa(im, Mat4d)

im = convert(Mat4d,jm)

@assert isa(im,Mat4d)
#@assert jm == im

@show jm2 = convert(Array{Float64,2},im)
@assert isa(jm2, Array{Float64,2})
@assert jm == jm2

#Single valued constructor
Matrix4x4(0.0) === zeros(Mat4d)
Vector4(0) == Vector4(0,0,0,0)
Point3(0) == Point3(0,0,0)

for i=1:10000
	v = rand(4)
	m = rand(4,4)
	vm = m * v
	vfs = Vector4(v)
	mfs = Matrix4x4(m)
	fsvm = mfs * vfs
	for i=1:4
		@assert isapprox(fsvm[i], vm[i]) "$(fsvm[i])  $(vm[i])"
	end
end

ac = rand(3)
bc = rand(3)

a = rand(4)
b = rand(4)
c = rand(4,4)

d = cross(ac, bc)
d2 = a+b
f = c*a
g = c*b
h = c*f
i = dot(f, a)
j = dot(a, g)
k = abs(f)
l = abs(-f)

acfs = Vector3(ac)
bcfs = Vector3(bc)

afs = Vector4(a)
bfs = Vector4(b)
cfs = Matrix4x4(c)

dfs = cross(acfs, bcfs)
d2fs = afs+bfs
ffs = cfs*afs
gfs = cfs*bfs
hfs = cfs*ffs
ifs = dot(ffs, afs)
jfs = dot(afs, gfs)
kfs = abs(ffs)
lfs = abs(-ffs)

function Base.isapprox{FSA <: FixedArray}(a::FSA, b::Array)
	for i=1:length(a)
		!isapprox(a[i], b[i]) && return false
	end
	true
end

@test isapprox(acfs, ac)
@test isapprox(bcfs, bc)

@test isapprox(afs, a)
@test isapprox(bfs, b)
@test isapprox(cfs, c)

@test isapprox(dfs, d)
@test isapprox(d2fs, d2)
@test isapprox(ffs, f)
@test isapprox(gfs, g)
@test isapprox(hfs, h)
@test isapprox(ifs, i)
@test isapprox(jfs, j)
@test isapprox(kfs, k)
@test isapprox(lfs, l)




import Base: (*)
function (*){T}(q::Quaternion{T}, v::Vector3{T}) 
    t = 2 * cross(Vector3(q.v1, q.v2, q.v3), v)
    v + q.s * t + cross(Vector3(q.v1, q.v2, q.v3), t)
end
function Quaternions.qrotation{T<:Real}(axis::Vector3{T}, theta::T)
    u = normalize(axis)
    s = sin(theta/2)
    Quaternion(cos(theta/2), s*u[1], s*u[2], s*u[3], true)
end


function rotationmatrixv{T}(q::Quaternion{T})
    sx, sy, sz = 2q.s*q.v1, 2q.s*q.v2, 2q.s*q.v3
    xx, xy, xz = 2q.v1^2, 2q.v1*q.v2, 2q.v1*q.v3
    yy, yz, zz = 2q.v2^2, 2q.v2*q.v3, 2q.v3^2

    Matrix3x3{T}(
        1-(yy+zz), xy+sz, xz-sy,
        xy-sz, 1-(xx+zz), yz+sx,
        xz+sy, yz-sx, 1-(xx+yy),
    )
end

function rotation{T}(u::Vector3{T}, v::Vector3{T})
    u = normalize(u)
    v = normalize(v)
    if (u == -v)
        # 180 degree rotation around any orthogonal vector
        other = (abs(dot(u, Vector3{T}(1,0,0))) < 1.0) ? Vector3{T}(1,0,0) : Vector3{T}(0,1,0)
        return qrotation(normalize(cross(u, other)), 180)
    end

    half = normalize(u + v)
    return Quaternion(dot(u, half), cross(u, half)...)
end

r = qrotation(ac, 0.77)
m = rotationmatrix(r)
z = r*ac

rfs = qrotation(acfs, 0.77)
mfs = rotationmatrixv(rfs)
zfs = rfs*acfs


println(mfs, m)
for i=1:4
	@test isapprox(r.(i), rfs.(i))
end 
@test isapprox(mfs, m)
println(z)
println(zfs)
@test isapprox(zfs, z)