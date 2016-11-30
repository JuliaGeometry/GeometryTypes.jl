@inline sqnorm(x) = sum(x.^2)

"""
pinvli{n,m,T}(a::Mat{n,m,T})

Compute pseudo inverse of matrix with linear independent columns.
"""
function pinvli{n,m,T}(a::Mat{n,m,T})
    @assert n >= m
    return inv(a'*a)*a'
end
