@testset "argmax" begin
    arg, val = GeometryTypes.argmax(sin, range(0, stop=π, length=101))
    @test arg ≈ π/2
    @test val ≈ 1

    arg, val = GeometryTypes.argmax(cos, range(0, stop=π, length=101))
    @test arg ≈ 0  # 0, not π, because argmax requires a subsequent value to be *strictly better* than the current best
    @test val ≈ 1.0

    @test @allocated(GeometryTypes.argmax(sin, range(0, stop=π, length=101))) == 0

    @test_throws ArgumentError GeometryTypes.argmax(identity, [])
end
