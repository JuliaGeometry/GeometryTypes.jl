context("faces") do
    a = [1,2,3,4]
    @fact a[Face{3,Int,0}(1,2,3)] --> (1,2,3)
    @fact a[Face{3,Int,-1}(0,1,2)] --> (1,2,3)
    @fact a[Face{3,Int,1}(2,3,4)] --> (1,2,3)
end
