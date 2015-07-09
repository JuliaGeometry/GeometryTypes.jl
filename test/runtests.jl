using GeometryTypes, FixedSizeArrays
using Base.Test




typealias Vec2d Vector2{Float64}
typealias Vec3d Vector3{Float64}
typealias Vec4d Vector4{Float64}
typealias Vec3f Vector3{Float32}

v1 = Vec3d(1.0,2.0,3.0)
v2 = Vec3d(6.0,5.0,4.0)

# indexing
@test v1[1] == 1.0
@test v1[2] == 2.0
@test v1[3] == 3.0
@test try v1[-1]; false; catch e; isa(e,BoundsError); end
@test try v1[0];  false; catch e; isa(e,BoundsError); end
@test try v1[4];  false; catch e; isa(e,BoundsError); end

# negation
@test -v1 == Vec3d(-1.0,-2.0,-3.0)
@test isa(-v1,Vec3d)

# addition
@test v1+v2 == Vec3d(7.0,7.0,7.0)

# subtraction
@test v2-v1 == Vec3d(5.0,3.0,1.0)

# multiplication
@test v1.*v2 == Vec3d(6.0,10.0,12.0)

# division
@test v1 ./ v1 == Vec3d(1.0,1.0,1.0)

# scalar operations
@test 1.0 + v1 == Vec3d(2.0,3.0,4.0)
@test 1.0 .+ v1 == Vec3d(2.0,3.0,4.0)
@test v1 + 1.0 == Vec3d(2.0,3.0,4.0)
@test v1 .+ 1.0 == Vec3d(2.0,3.0,4.0)
@test 1 + v1 == Vec3d(2.0,3.0,4.0)
@test 1 .+ v1 == Vec3d(2.0,3.0,4.0)
@test v1 + 1 == Vec3d(2.0,3.0,4.0)
@test v1 .+ 1 == Vec3d(2.0,3.0,4.0)

@test v1 - 1.0 == Vec3d(0.0,1.0,2.0)
@test v1 .- 1.0 == Vec3d(0.0,1.0,2.0)
@test 1.0 - v1 == Vec3d(0.0,-1.0,-2.0)
@test 1.0 .- v1 == Vec3d(0.0,-1.0,-2.0)
@test v1 - 1 == Vec3d(0.0,1.0,2.0)
@test v1 .- 1 == Vec3d(0.0,1.0,2.0)
@test 1 - v1 == Vec3d(0.0,-1.0,-2.0)
@test 1 .- v1 == Vec3d(0.0,-1.0,-2.0)

@test 2.0 * v1 == Vec3d(2.0,4.0,6.0)
@test 2.0 .* v1 == Vec3d(2.0,4.0,6.0)
@test v1 * 2.0 == Vec3d(2.0,4.0,6.0)
@test v1 .* 2.0 == Vec3d(2.0,4.0,6.0)
@test 2 * v1 == Vec3d(2.0,4.0,6.0)
@test 2 .* v1 == Vec3d(2.0,4.0,6.0)
@test v1 * 2 == Vec3d(2.0,4.0,6.0)
@test v1 .* 2 == Vec3d(2.0,4.0,6.0)

@test v1 / 2.0 == Vec3d(0.5,1.0,1.5)
@test v1 ./ 2.0 == Vec3d(0.5,1.0,1.5)
@test v1 / 2 == Vec3d(0.5,1.0,1.5)
@test v1 ./ 2 == Vec3d(0.5,1.0,1.5)

@test 12.0 ./ v1 == Vec3d(12.0,6.0,4.0)
@test 12 ./ v1 == Vec3d(12.0,6.0,4.0)

@test v1.^2 == Vec3d(1.0,4.0,9.0)
@test v1.^2.0 == Vec3d(1.0,4.0,9.0)
@test 2.0.^v1 == Vec3d(2.0,4.0,8.0)
@test 2.^v1 == Vec3d(2.0,4.0,8.0)

# vector norm
@test norm(Vec3d(1.0,2.0,2.0)) == 3.0

# cross product
@test cross(v1,v2) == Vec3d(-7.0,14.0,-7.0)
@test isa(cross(v1,v2),Vec3d)


# type conversion
@test isa(convert(Vec3f,v1), Vec3f)

@test isa(convert(Vector{Float64}, v1), Vector{Float64})
@test convert(Vector{Float64}, v1) == [1.0,2.0,3.0]


# matrix operations

#typealias Mat1d Matrix1x1{Float64}
typealias Mat2d Matrix2x2{Float64}
typealias Mat3d Matrix3x3{Float64}
typealias Mat4d Matrix4x4{Float64}

@test zero(Mat2d) == Mat2d(0.0,0.0,0.0,0.0)

v = Vec4d(1.0,2.0,3.0,4.0)
r = row(v)
c = column(v)

#@show prod(Vector1(0))
a = c*r
b = Mat4d(1.0,2.0,3.0,4.0,
             2.0,4.0,6.0,8.0,
             3.0,6.0,9.0,12.0,
             4.0,8.0,12.0,16.0)

@test a==b
#@test r*c == Matrix1x1(30.0)
#@test r' == c
#@test c' == r
#@test row(r,1) == v
#@test column(c,1) == v
#@test row(r+c',1) == 2*v
@test sum(r) == sum(v)
@test prod(c) == prod(v)
@test eye(Mat3d) == Mat3d(1.0,0.0,0.0,
							0.0,1.0,0.0,
							0.0,0.0,1.0)
#@test v*eye(Mat4d)*v == 30.0
@test -r == -1.0*r
#@test diag(diagm(v)) == v

# type conversion
#@test isa(convert(Matrix1x4{Float32},r),Matrix1x4{Float32})
jm = rand(4,4)
im = convert(Matrix4x4, jm)
#im = Matrix4x4(jm)
@test isa(im, Mat4d)

im = convert(Mat4d,jm)

@test isa(im,Mat4d)
#@test jm == im

jm2 = convert(Array{Float64,2},im)
@test isa(jm2, Array{Float64,2})
@test jm == jm2

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
		@test isapprox(fsvm[i], vm[i])
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
