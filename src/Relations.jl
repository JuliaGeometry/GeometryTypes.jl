export before, meets, overlaps, starts, during, finishes

# http://en.wikipedia.org/wiki/Allen%27s_interval_algebra

function before{T1, T2, N}(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2})
    for i = 1:N
        b1.maximum[i] < b2.minimum[i] || return false
    end
    true
end

@inline meets{T1, T2, N}(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2}) =
    b1.maximum == b2.minimum

function overlaps{T1, T2, N}(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2})
    for i = 1:N
        b2.maximum[i] > b1.maximum[i] > b2.minimum[i] && b1.minimum[i] < b2.minimum[i] || return false
    end
    true
end

function starts{T1, T2, N}(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2})
    if b1.minimum == b2.minimum
        for i = 1:N
            b1.maximum[i] < b2.maximum[i] || return false
        end
        return true
    else
        return false
    end
end

function during{T1, T2, N}(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2})
    for i = 1:N
        b1.maximum[i] < b2.maximum[i] && b1.minimum[i] > b2.minimum[i] || return false
    end
    true
end

function finishes{T1, T2, N}(b1::HyperRectangle{N, T1}, b2::HyperRectangle{N, T2})
    if b1.maximum == b2.maximum
        for i = 1:N
            b1.minimum[i] > b2.minimum[i] || return false
        end
        return true
    else
        return false
    end
end
