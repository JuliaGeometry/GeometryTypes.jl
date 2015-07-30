using GeometryTypes, FixedSizeArrays
using Base.Test


#t1 = ["1.909", "1.909", "1.909"]
#@test Vec{3, Float64}(1.909) == Vec{3, Float64}(t1)
#@test length(t1) == 3

typealias Vec2d Vec{2, Float64}
typealias Vec3d Vec{3, Float64}
typealias Vec4d Vec{4, Float64}
typealias Vec3f Vec{3, Float32}

v1 = Vec(1.0,2.0,3.0)
v2 = Vec(6.0,5.0,4.0)

# indexing
@test v1[1] == 1.0
@test v1[2] == 2.0
@test v1[3] == 3.0
@test_throws BoundsError v1[-1]
@test_throws BoundsError v1[0]
@test_throws BoundsError v1[4]

# negation
@test -v1 == Vec(-1.0,-2.0,-3.0)
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
typealias Mat2d Mat{2,2, Float64}
typealias Mat3d Mat{3,3, Float64}
typealias Mat4d Mat{4,4, Float64}
zeromat = Mat2d((0.0,0.0),(0.0,0.0))



@test length(Mat2d) == 4
@test length(zeromat) == 4

@test size(Mat2d) == (2,2)
@test size(zeromat) == (2,2)

@test zero(Mat2d) == zeromat

for i=1:4, j=1:4
	x1 = rand(i,j)
	@test Mat(x1') == Mat(x1)'
end



v = Vec(1.0,2.0,3.0,4.0)
r = row(v)
c = column(v)

#@test r' == c
#@test c' == r

a = c*r

b = Mat(
	(1.0,2.0,3.0,4.0),
	(2.0,4.0,6.0,8.0),
	(3.0,6.0,9.0,12.0),
	(4.0,8.0,12.0,16.0)
)

@test length(b) == 16

@test a==b
println(r)
println(c)
mat30 = Mat(((30.0,),))
println(column(r, 1))
println(row(r, 1))
@test r*c == mat30


#@test row(r, 1) == v
#@test column(c,1) == v
#@test row(r+c',1) == 2*v
@test sum(r) == sum(v)
@test prod(c) == prod(v)
eye(Mat3d)
@test eye(Mat3d) == Mat((1.0,0.0,0.0),
							(0.0,1.0,0.0),
							(0.0,0.0,1.0))
#@test v*eye(Mat4d)*v == 30.0
println(length(r))
@test -r == -1.0*r
#@test diag(diagm(v)) == v

# type conversion
#@test isa(convert(Matrix1x4{Float32},r),Matrix1x4{Float32})
jm = rand(4,4)
im = Mat(jm)
for i=1:4*2
	@test jm[i] == im[i]
end
#im = Matrix4x4(jm)
@test isa(im, Mat4d)

im = Mat(jm)

@test isa(im, Mat4d)
#@test jm == im

jm2 = convert(Array{Float64,2}, im)
@test isa(jm2, Array{Float64,2})
@test jm == jm2

#Single valued constructor
Mat4d(0.0) == zeros(Mat4d)
a = Vec4d(0)
b = Vec4d(0,0,0,0)
@test a == b

v = rand(4)
m = rand(4,4)
vfs = Vec(v)
mfs = Mat(m)
function lol()
	for i=1:10000
		v = rand(4)
		m = rand(4,4)
		vm = m * v
		vfs = Vec(v)
		mfs = Mat(m)
		fsvm = mfs * vfs
		for i=1:4
			@test isapprox(fsvm[i], vm[i])
		end
	end
end
#lol()

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

acfs = Vec(ac)
bcfs = Vec(bc)
println(acfs)

afs = Vec(a)
bfs = Vec(b)
cfs = Mat(c)

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

# Equality
@test Vec{3, Int}(1) == Vec{3, Float64}(1)
@test Vec{2, Int}(1) != Vec{3, Float64}(1)
@test Vec(1,2,3) == Vec(1.0,2.0,3.0)
@test Vec(1,2,3) != Vec(1.0,4.0,3.0)
@test Vec(1,2,3) == [1,2,3]
@test Mat((1,2),(3,4)) == Mat((1,2),(3,4))
let
    a = rand(16)
    b = Mat4d(a)
    @test b == reshape(a, (4,4))
    @test reshape(a, (4,4)) == b
    @test b != reshape(a, (2,8))
end

println("SUCCESS")

