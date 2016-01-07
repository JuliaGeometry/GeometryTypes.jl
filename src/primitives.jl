function call{T <: HMesh,HT}(meshtype::Type{T}, c::HyperRectangle{3,HT})
    ET = Float32
    xdir = Vec{3, ET}(widths(c)[1],0f0,0f0)
    ydir = Vec{3, ET}(0f0,widths(c)[2],0f0)
    zdir = Vec{3, ET}(0f0,0f0,widths(c)[3])
    quads = [
        Quad(origin(c) + zdir,   xdir, ydir), # Top
        Quad(origin(c),          ydir, xdir), # Bottom
        Quad(origin(c) + xdir,   ydir, zdir), # Right
        Quad(origin(c),          zdir, ydir), # Left
        Quad(origin(c),          xdir, zdir), # Back
        Quad(origin(c) + ydir,   zdir, xdir) #Front
    ]
    merge(map(meshtype, quads))
end

function call{T <: HMesh,HT}(meshtype::Type{T}, c::HyperCube{3,HT})
    ET = Float32
    xdir = Vec{3, ET}(c.width,0f0,0f0)
    ydir = Vec{3, ET}(0f0,c.width,0f0)
    zdir = Vec{3, ET}(0f0,0f0,c.width)
    quads = [
        Quad(origin(c) + zdir,   xdir, ydir), # Top
        Quad(origin(c),          ydir, xdir), # Bottom
        Quad(origin(c) + xdir,   ydir, zdir), # Right
        Quad(origin(c),          zdir, ydir), # Left
        Quad(origin(c),          xdir, zdir), # Back
        Quad(origin(c) + ydir,   zdir, xdir) #Front
    ]
    merge(map(meshtype, quads))
end

call{T <: HMesh}(meshtype::Type{T}, c::Pyramid) = T(decompose(vertextype(T), c), decompose(facetype(T), c))

spherical{T}(theta::T, phi::T) = Point{3, T}(
    sin(theta)*cos(phi),
    sin(theta)*sin(phi),
    cos(theta)
)

function call{MT <: AbstractMesh}(::Type{MT}, s::Sphere, facets=12)
    PT, FT = vertextype(MT), facetype(MT)
    FTE    = eltype(FT)
    PTE    = eltype(PT)

    vertices      = Array(PT, facets*facets+1)
    vertices[end] = PT(0, 0, -1) #Create a vertex for last triangle fan
    for j=1:facets
        theta = PTE((pi*(j-1))/facets)
        for i=1:facets
            position           = sub2ind((facets,), j, i)
            phi                = PTE((2*pi*(i-1))/facets)
            vertices[position] = (spherical(theta, phi)*PTE(s.r))+PT(s.center)
        end
    end
    indexes          = Array(FT, facets*facets*2)
    psydo_triangle_i = length(vertices)
    index            = 1
    for j=1:facets
        for i=1:facets
            next_index = mod1(i+1, facets)
            i1 = sub2ind((facets,), j, i)
            i2 = sub2ind((facets,), j, next_index)
            i3 = (j != facets) ? sub2ind((facets,), j+1, i)          : psydo_triangle_i
            i6 = (j != facets) ? sub2ind((facets,), j+1, next_index) : psydo_triangle_i
            indexes[index]   = FT(Triangle{FTE}(i1,i2,i3)) # convert to required Face index offset
            indexes[index+1] = FT(Triangle{FTE}(i3,i2,i6))
            index += 2
        end
    end
    MT(vertices, indexes)
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
