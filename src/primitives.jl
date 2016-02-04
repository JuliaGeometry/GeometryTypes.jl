
function call{T <: AbstractMesh}(meshtype::Type{T}, c::Pyramid)
    T(decompose(vertextype(T), c), decompose(facetype(T), c))
end
function call{T <: AbstractMesh}(meshtype::Type{T}, c::Sphere, facets=12)
    T(decompose(vertextype(T), c, facets), decompose(facetype(T), c, facets))
end

function call{T <: AbstractMesh}(meshtype::Type{T}, c::GeometryPrimitive, args...)
    attribs = attributes(T)
    newattribs = Dict{Symbol, Any}()
    for (fieldname, typ) in attribs
        if isdecomposable(eltype(typ), c)
            newattribs[fieldname] = decompose(eltype(typ), c, args...)
        end
    end
    T(homogenousmesh(newattribs))
end




signedpower(v, n) = sign(v)*abs(v)^n

immutable RoundedCube{T}
    power::T
end
export RoundedCube
function call{M <: AbstractMesh}(::Type{M}, c::RoundedCube, N=128)
    (N < 3) && error("Usage: $N nres rpower\n")
    # Create vertices
    L = (N+1)*(N÷2+1)
    has_texturecoordinates = true
    p = Array(vertextype(M), L)
    texture_coords = Array(UV{Float32}, L)
    faces = Array(facetype(M), N*2)
    NH = N÷2
    # Pole is along the z axis
    for j=0:NH
        for i=0:N
            index = j * (N+1) + i
            theta = i * 2 * pi / N
            phi   = -0.5*pi + pi * j / NH
            # Unit sphere, power determines roundness
            x,y,z = (
                signedpower(cos(phi), c.power) * signedpower(cos(theta), c.power),
                signedpower(cos(phi), c.power) * signedpower(sin(theta), c.power),
                signedpower(sin(phi), c.power)
            )
            if has_texturecoordinates
                u = abs(atan2(y,x) / (2*pi))
                texture_coords[index+1] = (u, 0.5 + atan2(z, sqrt(x*x+y*y)) / pi)
            end
            # Seams
            if j == 0;  x,y,z = 1,1,2; end
            if j == NH; x,y,z = 1,1,0; end
            if i == N;  x,y   = p[(j*(N+1)+i-N)+1]; end
            p[index+1] = (1-x,1-y,1-z)
        end
    end
    for j=0:(NH-1)
        for i=0:(N-1)
            i1 =  j    * (N+1) + i
            i2 =  j    * (N+1) + (i + 1)
            i3 = (j+1) * (N+1) + (i + 1)
            i4 = (j+1) * (N+1) + i
            faces[i*2+1] = (i1,i3,i4)
            faces[i*2+2] = (i1,i2,i3)
        end
    end
    M(p, faces)
end
