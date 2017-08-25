using Base.Cartesian

"""
deleteat{N,T,i}(x::NTuple{N,T}, ::Type{Val{i}})

Return copy of x with ith entry ommited.
"""
@generated function deleteat(x::NTuple{N,T}, ::Type{Val{i}}) where {N,T,i}
    (1 <= i <= N) || throw(MethodError(drop_index, (x,Val{i})))
    args = [:(x[$j]) for j in deleteat!([1:N...], i)]
    Expr(:tuple, args...)
end

"""
deleteat{N,T}(x::NTuple{N,T}, i::Int)
"""
@generated deleteat(x::NTuple{N,T}, i::Int) where {N,T} = quote
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


w_component(::Type{Point{N, T}}) where {N, T} = T(1)
w_component(::Type{Vec{N, T}}) where {N, T} = T(0)

@generated function transform_convert(::Type{T1}, x::T2) where {T1 <: StaticVector, T2 <: StaticVector}
    w = w_component(T1)
    n1 = length(T1)
    n2 = length(T2)
    n1 <= n2 && return :(T1(x))
    tupl = Expr(:tuple)
    ET = eltype(T1)
    for i = 1:n2
        push!(tupl.args, :($ET(x[$i])))
    end
    for i = 1:(n1 - n2 - 1)
        push!(tupl.args, :($ET(0)))
    end
    push!(tupl.args, :($w))
    :(T1($tupl))
end
