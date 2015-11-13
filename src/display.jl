# functions related to displaying types

function show{M <: HMesh}(io::IO, m::M)
    println(io, "HomogenousMesh(")
    for (key,val) in attributes(m)
        print(io, "    ", key, ": ", length(val), "x", eltype(val), ", ")
    end
    println(io, ")")
end

function Base.show(io::IO, p::PureSimplicialComplex)
    println(typeof(p).name)
    for i in p.simplices
        println("$(typeof(i)) (length: $(length(i))):")
        println(i)
    end
end
