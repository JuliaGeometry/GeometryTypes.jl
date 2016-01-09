

function scale!{N,T1}(poly::Polytope{N,T1}, pt)
    elts = elements(poly)
    @inbounds for i = eachindex(elts)
        v = elts[i]
        elts[i] = v.*pt
    end
end
