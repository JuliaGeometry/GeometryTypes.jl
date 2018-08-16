using StaticArrays

function parseGtsLine( s::AbstractString, T=Int )
    firstInd = findfirst( isequal(' '), s )
    secondInd = findnext( isequal(' '), s, firstInd+1 )
    firstNum = parse( T, s[1:firstInd] )
    if secondInd != 0
        secondNum = parse( T, s[firstInd:secondInd] )
        thirdNum = parse( T, s[secondInd:end] )
        return @SVector [firstNum, secondNum, thirdNum]
    else
        secondNum = parse( T, s[firstInd:end] )
        return @SVector [firstNum, secondNum]
    end
end

function parseGtsFile( fileName::AbstractString )
    file = open( fileName, "r" )
    head = readline( file )
    body = readlines( file )
    close( file )
    nNodes, nEdges, nFacets = parseGtsLine( head )
    nodes = parseGtsLine.( body[1:nNodes], Float64 )
    edges = parseGtsLine.( body[nNodes+1:nNodes+nEdges] )
    facets = parseGtsLine.( body[nNodes+nEdges+1:end] )
    return (
        nodes,
        edges,
        facets,
        [ SVector{3,Int}( union( edges[facets[i][1]], edges[facets[i][2]], edges[facets[i][3]] ) ) for i in 1:length(facets) ]      #faces
    )
end
