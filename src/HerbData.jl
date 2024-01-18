module HerbData

using Serialization

export 
    Problem,
    Example,
    IOExample,

    readdata,
    readfile,

    read_IOexamples,
    write_IOexamples,


abstract type Example end

"""
    struct Problem

Program synthesis problem defined with a vector of [`Example`](@ref)s
"""
struct Problem
    examples::AbstractVector{Example}
end

"""
    Base.getindex(p::Problem, indices) = Problem(p.examples[indices])

Overwrite `Base.getindex` to access allow for slicing of problems.
"""
Base.getindex(p::Problem, indices) = Problem(p.examples[indices])

"""
    struct IOExample <: Example

An input-output example.
`input` is a [`Dict`](@ref) of `{Symbol,Any}` where the symbol represents a variable in a program.
`output` can be anything.
"""
struct IOExample <: Example
    in::Dict{Symbol, Any}
    out::Any
end


"""
    readdata(directory::AbstractString, lineparser::Function)::Vector{Problem}

Reads all files in the given directory and parses them line by line into an 
`ExampleProblem` using the given lineparser.

*TODO: Turn this into an iterator that doesn't load all data into memory
at initialization.*
"""
function readdata(directory::AbstractString, lineparser::Function)::Vector{Problem}
    data::Vector{Problem} = Vector([]) 
    for filename ∈ readdir(directory)
        filepath = joinpath(directory, filename)
        push!(data, readfile(filepath, lineparser))
    end
    return data
end

"""
    readfile(filepath::AbstractString, lineparser::Function)::Problem

Reads a file and parses every non-empty line using the line parser.
"""
function readfile(filepath::AbstractString, lineparser::Function)::Problem
    file = open(filepath)
    examples::Vector{Example} = map(lineparser, readlines(file))
    close(file)
    return Problem(examples, basename(filepath))
end

"""
    write_IOexamples(filepath::AbstractString, examples::Vector{IOExample})

Writes IO examples to disk by serializing them into a file using HDF5 checking for and appending the `.xio` file ending.
"""
function write_IOexamples(filepath::AbstractString, examples::Vector{IOExample})
    serialize(filepath * (endswith(filepath, ".xio") ? "" : ".xio"), examples)
end


"""
    read_IOexamples(filepath::AbstractString)::Vector{IOExample}

Reads serialized IO examples from disk after type checking.
"""
function read_IOexamples(filepath::AbstractString)::Vector{IOExample}
    @assert endswith(filepath, ".xio")
    return deserialize(filepath)
end
end # module HerbData
