module Operations

using HyperRectangles

export update!

function update!{T, N}(b::HyperRectangle{T, N}, v)
    for i = 1:N
        b.max[i] = max(b.max[i], v[i])
        b.min[i] = min(b.min[i], v[i])
    end
end

end # module
