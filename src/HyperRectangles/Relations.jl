export before, meets, overlaps, starts, during, finishes

# http://en.wikipedia.org/wiki/Allen%27s_interval_algebra

function before{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    for i = 1:N
        b1.max[i] < b2.min[i] || return false
    end
    true
end

@inline meets{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N}) =
    b1.max == b2.min

function overlaps{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    for i = 1:N
        b2.max[i] > b1.max[i] > b2.min[i] && b1.min[i] < b2.min[i] || return false
    end
    true
end

function starts{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    if b1.min == b2.min
        for i = 1:N
            b1.max[i] < b2.max[i] || return false
        end
        return true
    else
        return false
    end
end

function during{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    for i = 1:N
        b1.max[i] < b2.max[i] && b1.min[i] > b2.min[i] || return false
    end
    true
end

function finishes{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    if b1.max == b2.max
        for i = 1:N
            b1.min[i] > b2.min[i] || return false
        end
        return true
    else
        return false
    end
end
