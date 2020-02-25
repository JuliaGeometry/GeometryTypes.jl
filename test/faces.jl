@testset "faces" begin

    @testset "constructors" begin
        f1 = Face(1,2,3)
        @test Face{3, ZeroIndex{Int}}(f1) == Face{3, Int}(1,2,3)
        # round trip
        i = 2
        tmp = Face{3, OffsetInteger{3, Int32}}(Face{3}(ZeroIndex{Int}(i)))
        @test Int(tmp[1]) == i
    end

    @testset "getindex" begin
        a = [1,2,3,4]
        @test a[Face{3, Int}(1,2,3)] == (1,2,3)
        @test a[Face{3, ZeroIndex{Int}}(1,2,3)] == (1,2,3)
    end

    @testset "setindex" begin
        a = [1,2,3,4]
        a[Face(1,2,3)] = [7,6,5]
        @test a == [7,6,5,4]
    end

    @testset "views" begin
        x = GLNormalMesh(AABB(Vec3f0(0), Vec3f0(1)))
        v = view(vertices(x), faces(x))
        vs = vertices(x)
        vf = [vs[face] for face in faces(x)]
        @test v == vf
    end

    @testset "negative offsets and unsigned integers" begin
        oi = OffsetInteger{-1, UInt64}(UInt64(1))
        show(IOBuffer(), oi)

        oi = OffsetInteger{1, UInt64}(UInt64(1))
        show(IOBuffer(), oi)
    end

    @testset "sorting of offsets" begin
        o1 = OffsetInteger{-2, Int}(-1)
        o2 = OffsetInteger{-2, Int}(0)
        o3 = OffsetInteger{-2, Int}(1)
        @test o1 < o2
        @test sort([o3, o1, o2]) == [o1, o2, o3]
    end

    @testset "operations on offsets" begin
        o1 = OffsetInteger{-2, Int}(-1)
        o2 = OffsetInteger{-2, Int}(0)
        o3 = OffsetInteger{-2, Int}(1)
        @test abs(o2) === o2
        @test abs(o1) === o3
        @test o1 + o3 === o2
        @test -o1 === o3
        @test -o3 === o1
        @test -o2 === o2
    end
end
