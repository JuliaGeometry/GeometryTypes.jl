# functions related to displaying types

function show(io::IO, m::M) where M <: HMesh
    println(io, "HomogenousMesh(")
    for (key,val) in attributes(m)
        print(io, "    ", key, ": ", length(val), "x", eltype(val), ", ")
    end
    println(io, ")")
end
