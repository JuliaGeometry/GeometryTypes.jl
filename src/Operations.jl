module Operations

using HyperRectangles

export update!, points

function update!{T, N}(b::HyperRectangle{T, N}, v)
    for i = 1:N
        b.max[i] = max(b.max[i], v[i])
        b.min[i] = min(b.min[i], v[i])
    end
end

function points{T}(rect::HyperRectangle{T, 3})
    Vector{T}[rect.min,
        [rect.min[1],rect.min[2],rect.max[3]],
        [rect.min[1],rect.max[2],rect.min[3]],
        [rect.min[1],rect.max[2],rect.max[3]],
        [rect.max[1],rect.min[2],rect.min[3]],
        [rect.max[1],rect.min[2],rect.max[3]],
        [rect.max[1],rect.max[2],rect.min[3]],
        rect.max]
end

function points{T}(rect::HyperRectangle{T, 2})
    Vector{T}[rect.min,
        [rect.min[1],rect.max[2]],
        [rect.max[1],rect.min[2]],
        rect.max]
end

end # module
