using GeometryTypes
using FactCheck

typealias Vec1d Vec{1, Float64}
typealias Vec2d Vec{2, Float64}
typealias Vec3d Vec{3, Float64}
typealias Vec4d Vec{4, Float64}
typealias Vec3f Vec{3, Float32}

facts("Array of FixedArrays") do
    N = 100
    a = Point{3, Float32}[Point{3, Float32}(0.7132) for i=1:N]

    c = Point{3, Float64}[Point{3, Float64}(typemin(Float64)), a..., Point{3, Float64}(typemax(Float64))]

    context("reduce") do
        sa = sum(a)
        ma = mean(a)
        for i=1:3
            @fact sa[i]  --> roughly(Float32(0.7132*N))
            @fact ma[i]  --> roughly(Float32(0.7132*N)/ N)

        end

        @fact maximum(c) --> Point{3, Float32}(typemax(Float64))
        @fact minimum(c) --> Point{3, Float32}(typemin(Float64))

    end

    context("array ops") do
        af = a + 1f0     
        for elem in af 
            @fact a[1] + 1f0 --> elem
        end
    end

end



# A little brutal, but hey.... Better redudantant tests, than not enough tests
facts("Constructor ") do
    for N=1:3:10
        context("construction, conversion, $N") do
            for VT=[Point, Vec, Normal], VT2=[Normal, Vec, Point], ET=[Float32, Int, Uint, Float64], ET2=[Float64, Uint, Int, Float32]
                rand_range  = ET(1):ET(10)
                rand_range2 = ET2(1):ET2(10)
                rn = rand(rand_range, N)
                v0 = VT(rn)
                # parse constructor:
                @fact VT{N, ET}(map(string, rn)) --> v0
                # multi constructor
                v1 = VT{N, ET}(rn...)
                @fact v1 --> v0
                @fact typeof(v1) --> VT{N, ET}
                @fact length(v1) --> N
                @fact eltype(v1) --> ET
                @fact ndims(v1) --> 1

                @fact length(typeof(v1)) --> N
                @fact eltype(typeof(v1)) --> ET

                for i=1:N
                    @fact v1[i] --> rn[i]
                end
                # from other FSA without parameters
                v2 = VT2(v1)

                @fact typeof(v2) --> VT2{N, ET}
                @fact length(v2) --> N
                @fact eltype(v2) --> ET
                for i=1:N
                    @fact v2[i] --> v1[i]
                end
                # from other FSA with parameters
                for i=1:N
                    v3 = VT2{i, ET2}(v1)
                    @fact typeof(v3) --> VT2{i, ET2}
                    @fact length(v3) --> i
                    @fact eltype(v3) --> ET2
                    for i=1:i
                        @fact v3[i] --> ET2(v2[i])
                    end
                end
                # from single
                r  = rand(rand_range)
                r2 = rand(rand_range2)
                v1 = VT{N, ET}(r)
                v2 = VT{N, ET2}(r)
                v3 = VT{N, ET}(r2)
                v4 = VT{N, ET2}(r2)

                for i=1:N
                    @fact v1[i] --> r
                    @fact v2[i] --> ET2(r)
                    @fact v3[i] --> r2
                    @fact v4[i] --> ET2(r2)
                end
                x = VT{N, ET}[VT{N, ET}(1) for i=1:10]
                x1 = VT2{N, ET}[VT{N, ET}(1) for i=1:10]
                x2 = map(VT2, x)
                x3 = map(VT, x2)
                @fact typeof(x)  --> Vector{VT{N, ET}}
                @fact typeof(x1) --> Vector{VT2{N, ET}}
                @fact typeof(x2) --> Vector{VT2{N, ET}}
                @fact typeof(x3) --> Vector{VT{N, ET}}
                @fact x3         --> x
            end
        end
    end
end




facts("Constructors") do
    context("FixedVector: unary, from FixedVector") do
        @fact typeof(Vec3f(1,1,1))     --> Vec{3, Float32}
        @fact typeof(Vec3f(1,1f0,1))   --> Vec{3, Float32}
        @fact typeof(Vec3f(1f0,1,1.0)) --> Vec{3, Float32}

        @fact typeof(Vec3f(1))      --> Vec{3, Float32}
        @fact typeof(Vec3f(0))      --> Vec{3, Float32}
        @fact Vec3f(1.0)            --> Vec(1f0,1f0,1f0)
        @fact Vec3f(1.0f0)          --> Vec(1f0,1f0,1f0)
        @fact Vec3f(1.0f0)          --> Vec3f(1)
        @fact Vec(1.0, 1.0, 1.0)    --> Vec3d(1)
        @fact Vec2d(Vec3d(1))       --> Vec(1.0, 1.0)
        @fact Vec(Vec3d(1), 1.0)    --> Vec4d(1)
        @fact Vec(Vec3d(1), 1)      --> Vec4d(1)
        @fact Vec3d(Vec3f(1.0))     --> Vec3d(1.0)
    end
end
v2 = Vec(6.0,5.0,4.0)
v1 = Vec(1.0,2.0,3.0)
v2 = Vec(6.0,5.0,4.0)

facts("Indexing") do
    context("FixedVector") do
        @fact v1[1] --> 1.0
        @fact v1[2] --> 2.0
        @fact v1[3] --> 3.0
        @fact v1[1:3] --> (1.0, 2.0, 3.0)
        @fact v1[1:2] --> (1.0, 2.0)
        @fact v1[1:1] --> (1.0,)
        @fact_throws BoundsError v1[-1]
        @fact_throws BoundsError v1[0]
        @fact_throws BoundsError v1[4]
    end
    m = Mat{4,4,Int}(
        (1,2,3,4),
        (5,6,7,8),
        (9,10,11,12),
        (13,14,15,16)
    )
    context("FixedMatrix") do
        @fact m[1] --> 1
        @fact m[2] --> 2
        @fact m[10] --> 10
        @fact m[2,2] --> 6
        @fact m[3,4] --> 15
        @fact m[1:4, 1] --> (1,5,9,13)
        @fact m[1, 1:4] --> (1,2,3,4)
        @fact_throws BoundsError m[-1]
        @fact_throws BoundsError m[0]
        @fact_throws BoundsError m[17]
        @fact_throws BoundsError m[5,1]
        @fact_throws BoundsError m[-1,1]
        @fact_throws BoundsError m[0,0]
    end

end


facts("Ops") do
    context("Negation") do
        @fact -v1 --> Vec(-1.0,-2.0,-3.0)
        @fact isa(-v1, Vec3d) --> true
    end

    context("Negation") do
        @fact v1+v2 --> Vec3d(7.0,7.0,7.0)
    end
    context("Negation") do
        @fact v2-v1 --> Vec3d(5.0,3.0,1.0)
    end
    context("Multiplication") do
        @fact v1.*v2 --> Vec3d(6.0,10.0,12.0)
    end
    context("Division") do
        @fact v1 ./ v1 --> Vec3d(1.0,1.0,1.0)
    end

    context("Scalar") do
        @fact 1.0 + v1 --> Vec3d(2.0,3.0,4.0)
        @fact 1.0 .+ v1 --> Vec3d(2.0,3.0,4.0)
        @fact v1 + 1.0 --> Vec3d(2.0,3.0,4.0)
        @fact v1 .+ 1.0 --> Vec3d(2.0,3.0,4.0)
        @fact 1 + v1 --> Vec3d(2.0,3.0,4.0)
        @fact 1 .+ v1 --> Vec3d(2.0,3.0,4.0)
        @fact v1 + 1 --> Vec3d(2.0,3.0,4.0)
        @fact v1 .+ 1 --> Vec3d(2.0,3.0,4.0)

        @fact v1 - 1.0 --> Vec3d(0.0,1.0,2.0)
        @fact v1 .- 1.0 --> Vec3d(0.0,1.0,2.0)
        @fact 1.0 - v1 --> Vec3d(0.0,-1.0,-2.0)
        @fact 1.0 .- v1 --> Vec3d(0.0,-1.0,-2.0)
        @fact v1 - 1 --> Vec3d(0.0,1.0,2.0)
        @fact v1 .- 1 --> Vec3d(0.0,1.0,2.0)
        @fact 1 - v1 --> Vec3d(0.0,-1.0,-2.0)
        @fact 1 .- v1 --> Vec3d(0.0,-1.0,-2.0)

        @fact 2.0 * v1 --> Vec3d(2.0,4.0,6.0)
        @fact 2.0 .* v1 --> Vec3d(2.0,4.0,6.0)
        @fact v1 * 2.0 --> Vec3d(2.0,4.0,6.0)
        @fact v1 .* 2.0 --> Vec3d(2.0,4.0,6.0)
        @fact 2 * v1 --> Vec3d(2.0,4.0,6.0)
        @fact 2 .* v1 --> Vec3d(2.0,4.0,6.0)
        @fact v1 * 2 --> Vec3d(2.0,4.0,6.0)
        @fact v1 .* 2 --> Vec3d(2.0,4.0,6.0)

        @fact v1 / 2.0 --> Vec3d(0.5,1.0,1.5)
        @fact v1 ./ 2.0 --> Vec3d(0.5,1.0,1.5)
        @fact v1 / 2 --> Vec3d(0.5,1.0,1.5)
        @fact v1 ./ 2 --> Vec3d(0.5,1.0,1.5)

        @fact 12.0 ./ v1 --> Vec3d(12.0,6.0,4.0)
        @fact 12 ./ v1 --> Vec3d(12.0,6.0,4.0)

        @fact (v1 .^ 2) --> Vec3d(1.0,4.0,9.0)
        @fact (v1 .^ 2.0) --> Vec3d(1.0,4.0,9.0)
        @fact (2.0 .^ v1) --> Vec3d(2.0,4.0,8.0)
        @fact (2 .^ v1) --> Vec3d(2.0,4.0,8.0)
    end
    context("vector norm+cross product") do
        @fact norm(Vec3d(1.0,2.0,2.0)) --> 3.0

        # cross product
        @fact cross(v1,v2) --> Vec3d(-7.0,14.0,-7.0)
        @fact isa(cross(v1,v2),Vec3d)  --> true
    end

end





# type conversion
facts("Conversion 2") do
    @fact isa(convert(Vec3f,v1), Vec3f)  --> true

    @fact isa(convert(Vector{Float64}, v1), Vector{Float64})  --> true
    @fact convert(Vector{Float64}, v1) --> [1.0,2.0,3.0]
end

# matrix operations

#typealias Mat1d Matrix1x1{Float64}
typealias Mat2d Mat{2,2, Float64}
typealias Mat3d Mat{3,3, Float64}
typealias Mat4d Mat{4,4, Float64}

zeromat = Mat2d((0.0,0.0),(0.0,0.0))



@fact length(Mat2d) --> 4
@fact length(zeromat) --> 4

@fact size(Mat2d) --> (2,2)
@fact size(zeromat) --> (2,2)

@fact zero(Mat2d) --> zeromat

for i=1:4, j=1:4
    x1 = rand(i,j)
    @fact Mat(x1') --> Mat(x1)'
end


facts("Matrix") do
    v = Vec(1.0,2.0,3.0,4.0)
    r = row(v)
    c = column(v)

    #@fact r' --> c
    #@fact c' --> r

    a = c*r

    b = Mat(
        (1.0,2.0,3.0,4.0),
        (2.0,4.0,6.0,8.0),
        (3.0,6.0,9.0,12.0),
        (4.0,8.0,12.0,16.0)
    )

    @fact length(b) --> 16

    @fact a-->b
    mat30 = Mat(((30.0,),))
    @fact r*c --> mat30


    #@fact row(r, 1) --> v
    #@fact column(c,1) --> v
    #@fact row(r+c',1) --> 2*v
    @fact sum(r) --> sum(v)
    @fact prod(c) --> prod(v)

    @fact eye(Mat3d) --> Mat((1.0,0.0,0.0),
                                (0.0,1.0,0.0),
                                (0.0,0.0,1.0))
    #@fact v*eye(Mat4d)*v --> 30.0
    @fact -r --> -1.0*r
    #@fact diag(diagm(v)) --> v

    # type conversion
    #@fact isa(convert(Matrix1x4{Float32},r),Matrix1x4{Float32})
    jm = rand(4,4)
    im = Mat(jm)
    for i=1:4*2
        @fact jm[i] --> im[i]
    end
    #im = Matrix4x4(jm)
    @fact isa(im, Mat4d)  --> true

    jm2 = convert(Array{Float64,2}, im)
    @fact isa(jm2, Array{Float64,2})  --> true
    @fact jm --> jm2

    #Single valued constructor
    @fact Mat4d(0.0) --> zero(Mat4d)

    a = Vec4d(0)
    b = Vec4d(0,0,0,0)
    @fact a --> b

    v = rand(4)
    m = rand(4,4)
    vfs = Vec(v)
    mfs = Mat(m)
    @fact typeof(vfs) --> Vec4d
    @fact typeof(mfs) --> Mat4d
end

facts("Matrix Math") do
    for i=1:4, j=1:4
        v = rand(j)
        m = rand(i,j)
        vfs = Vec(v)
        mfs = Mat(m)

        context("Matrix{$i, $j} * Vector{$j}") do
            vm = m * v
            fsvm = mfs * vfs
            @fact isapprox(fsvm, vm)  --> true
        end
        if i == j
            context("Matrix{$i, $j} * Matrix{$i, $j}") do
                mm = m * m
                fmm = mfs * mfs
                @fact isapprox(fmm, mm)  --> true
            end
            context("det(M)") do
                mm = det(m)
                fmm = det(mfs)
                @fact isapprox(fmm, mm)  --> true
            end
            context("inv(M)") do
                mm = inv(m)
                fmm = inv(mfs)
                @fact isapprox(fmm, mm)  --> true
            end
        else
            context("Matrix{$i, $j} * Matrix{$i, $j}") do
                @fact_throws DimensionMismatch mfs * mfs
            end
        end

        context("transpose M") do
            mm = m'
            fmm = mfs'
            @fact isapprox(fmm, mm)  --> true
        end
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

acfs = Vec(ac)
bcfs = Vec(bc)

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


facts("Vector Math") do
    context("all") do
        @fact isapprox(acfs, ac)  --> true
        @fact isapprox(bcfs, bc)  --> true

        @fact isapprox(afs, a) --> true
        @fact isapprox(bfs, b) --> true
        @fact isapprox(cfs, c) --> true

        @fact isapprox(dfs, d) --> true
        @fact isapprox(d2fs, d2) --> true
        @fact isapprox(ffs, f) --> true
        @fact isapprox(gfs, g) --> true
        @fact isapprox(hfs, h) --> true
        @fact isapprox(ifs, i) --> true
        @fact isapprox(jfs, j) --> true
        @fact isapprox(kfs, k) --> true
        @fact isapprox(lfs, l) --> true
    end
end

facts("Equality") do
    @fact Vec{3, Int}(1) --> Vec{3, Float64}(1)
    @fact Vec{2, Int}(1) --> not(Vec{3, Float64}(1))
    @fact Vec(1,2,3) --> Vec(1.0,2.0,3.0)
    @fact Vec(1,2,3) --> not(Vec(1.0,4.0,3.0))
    @fact Vec(1,2,3) --> [1,2,3]
    @fact Mat((1,2),(3,4)) --> Mat((1,2),(3,4))
end
#=
#don't have this yet
let
    a = rand(16)
    b = Mat4d(a)
    @fact b --> reshape(a, (4,4))
    @fact reshape(a, (4,4)) --> b
    @fact b --> not(reshape(a, (2,8)))
end
=#

const unaryOps = (
    -, ~, conj, abs,
    sin, cos, tan, sinh, cosh, tanh,
    asin, acos, atan, asinh, acosh, atanh,
    sec, csc, cot, asec, acsc, acot,
    sech, csch, coth, asech, acsch, acoth,
    sinc, cosc, cosd, cotd, cscd, secd,
    sind, tand, acosd, acotd, acscd, asecd,
    asind, atand, rad2deg, deg2rad,
    log, log2, log10, log1p, exponent, exp,
    exp2, expm1, cbrt, sqrt, erf,
    erfc, erfcx, erfi, dawson,

    #trunc, round, ceil, floor, #see JuliaLang/julia#12163
    significand, lgamma, hypot,
    gamma, lfact, frexp, modf, airy, airyai,
    airyprime, airyaiprime, airybi, airybiprime,
    besselj0, besselj1, bessely0, bessely1,
    eta, zeta, digamma
)

# vec-vec and vec-scalar
const binaryOps = (
    .+, .-,.*, ./, .\, /,
    .==, .!=, .<, .<=, .>, .>=, +, -,
    min, max,

    atan2, besselj, bessely, hankelh1, hankelh2,
    besseli, besselk, beta, lbeta
)




facts("mapping operators") do
     context("binary: ") do
        test1 = (Vec(1,2,typemax(Int)), Mat((typemin(Int),2,5), (2,3,5), (-2,3,6)), Vec{4, Float32}(0.777))
        test2 = (Vec(1,0,typemax(Int)), Mat((typemin(Int),77,1), (2,typemax(Int),5), (-2,3,6)), Vec{4, Float32}(-23.2929))
        for op in binaryOps
            for i=1:length(test1)
                v1 = test1[i]
                v2 = test2[i]
                context("$op with $v1 and $v2") do
                    try # really bad tests, but better than nothing...
                        if applicable(op, v1[1], v2[1]) && typeof(op(v1[1], v2[1])) == eltype(v1)
                            r = op(v1, v2)
                            for j=1:length(v1)
                                @fact r[j] --> op(v1[j], v2[j])
                            end

                        end
                    catch e
                        println(e)
                    end
                end
            end
        end
    end
    context("unary: ") do
        test = (Vec(1,2,typemax(Int)), Mat((typemin(Int),2,5), (2,3,5), (-2,3,6)), Vec{4, Float32}(0.777))
        for op in unaryOps
            for t in test
                context("$op with $t") do
                    try
                        if applicable(op, t[1]) && typeof(op(t[1])) == eltype(t)
                            v = op(t)
                            for i=1:length(v)
                                @fact v[i] --> op(t[i])
                            end
                        end
                    catch e
                        println(e)
                    end
                end
            end
        end
    end
end



FactCheck.exitstatus()
