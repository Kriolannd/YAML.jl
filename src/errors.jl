module YAMLErrors

using LibYAML

export YAMLError,
    YAMLMemoryError,
    YAMLReaderError,
    YAMLScannerError,
    YAMLParserError,
    throw_yaml_err


abstract type AbstractYAMLError <: Exception end

struct YAMLError <: AbstractYAMLError
    msg::String
end


struct YAMLMemoryError <: AbstractYAMLError
    ctx::String
    problem::String
end


struct YAMLReaderError <: AbstractYAMLError
    ctx::String
    problem::String
end


struct YAMLScannerError <: AbstractYAMLError
    ctx::String
    problem::String
end


struct YAMLParserError <: AbstractYAMLError
    ctx::String
    problem::String
end


function Base.showerror(io::IO, err::AbstractYAMLError)
    print(io, "[CONTEXT]: $(err.ctx) | [ERROR]: $(err.problem)")
end


function Base.showerror(io::IO, err::YAMLError)
    print(io, err.msg)
end


function throw_yaml_err(type::yaml_error_type_e, context::String, problem::String)
    if type == YAML_MEMORY_ERROR
        throw(YAMLMemoryError(context, problem))
    elseif type == YAML_READER_ERROR
        throw(YAMLReaderError(context, problem))
    elseif type == YAML_SCANNER_ERROR
        throw(YAMLScannerError(context, problem))
    elseif type == YAML_PARSER_ERROR
        throw(YAMLParserError(context, problem))
    end

    return nothing
end

end # module YAMLErrors