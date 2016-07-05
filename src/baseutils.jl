using Base.Cartesian

"""
deleteat{N,T,i}(x::NTuple{N,T}, ::Type{Val{i}})

Return copy of x with ith entry ommited.
"""
@generated function deleteat{N,T,i}(x::NTuple{N,T}, ::Type{Val{i}})
    (1 <= i <= N) || throw(MethodError(drop_index, (x,Val{i})))
    args = [:(x[$j]) for j in deleteat!([1:N...], i)]
    Expr(:tuple, args...)
end

"""
deleteat{N,T}(x::NTuple{N,T}, i::Int)
"""
@generated deleteat{N,T}(x::NTuple{N,T}, i::Int) = quote
    # would be nice to eliminate boundscheck
    (1 <= i <= N) || throw(BoundsError(x,i))
    @nif $(N) d->(i==d) d-> deleteat(x, Val{d})
end

"""
best_arg, best_val = argmax(f, iter)

Computes the first element of iterator, on which f takes its maximum.
"""
function argmax(f, iter)
    state = start(iter)
    best_arg, state = next(iter, state)
    best_val = f(best_arg)
    while !done(iter,state)
        arg, state = next(iter,state)
        val = f(arg)
        if val > best_val
            best_val = val
            best_arg = arg
        end
    end
    best_arg, best_val
end
