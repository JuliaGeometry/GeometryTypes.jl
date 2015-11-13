"""
Determine if a `PureSimplicialComplex{3}` is closed. This checks that for
all edges, there is one with the opposite orientation.
"""
function isclosed(p::PureSimplicialComplex{3})
    edges = p.simplices[2]
    for edge in edges
        opposite_edge = Simplex(edge[2], edge[1])
        if opposite_edge in edges
            continue
        else
            return false
        end
    end
    true
end
