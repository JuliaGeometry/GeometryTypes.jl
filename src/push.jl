"""
Add a Simplex to a PureSimplicialComplex.
"""
function Base.push!{N1,N2}(p::PureSimplicialComplex{N1}, s::Simplex{N2})
    @assert N2 <= N1 # otherwise we would have type unstability
    for i = 1:N1
        faces = decompose(Simplex{i}, s)
        for face in faces
            push!(p.simplices[i], face)
        end
    end
end
