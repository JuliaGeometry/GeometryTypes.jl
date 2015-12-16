context("faces") do

context("constructors") do
    f1 = Face(1,2,3)
    @fact f1 --> Face{3,Int,0}(1,2,3)
    @fact Face{3,Int,0}(f1) --> f1
    @fact Face{3,UInt8,0}(f1) --> Face{3,UInt8,0}(1,2,3)
    @fact Face{3,Int,-1}(f1) --> Face{3,Int,-1}(0,1,2)
end

context("getindex") do
    a = [1,2,3,4]
    @fact a[Face{3,Int,0}(1,2,3)] --> (1,2,3)
    @fact a[Face{3,Int,-1}(0,1,2)] --> (1,2,3)
    @fact a[Face{3,Int,1}(2,3,4)] --> (1,2,3)
end

context("setindex") do
    a = [1,2,3,4]
    a[Face(1,2,3)] = [7,6,5]
    @fact a --> [7,6,5,4]
end

end
