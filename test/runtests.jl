using Bounds
using Base.Test

# write your own tests here
a = Bound(Float64, 4)
@test a == Bound{Float64,4}([Inf,Inf,Inf,Inf],[-Inf,-Inf,-Inf,-Inf])

update!(a, [1,2,3,4])

@test a == Bound{Float64,4}([1.0,2.0,3.0,4.0],[1.0,2.0,3.0,4.0])
@test a != Bound{Float64,4}([3.0,2.0,3.0,4.0],[1.0,2.0,3.0,4.0])

update!(a, [5,6,7,8])

@test a == Bound{Float64,4}([1.0,2.0,3.0,4.0],[5.0,6.0,7.0,8.0])

b = Bound{Float64,4}([1.0,2.0,3.0,4.0],[5.0,6.0,7.0,8.0])

@test in(a,b) && in(b,a) && contains(a,b) && contains(b,a)

c = Bound{Float64,4}([1.1,2.1,3.1,4.1],[4.0,5.0,6.0,7.0])

@test !in(a,c) && in(c,a) && contains(a,c) && !contains(c,a)
