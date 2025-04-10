module YAMLErrors

using LibYAML

export YAMLError,
    YAMLMemoryError,
    YAMLReaderError,
    YAMLScannerError,
    YAMLParserError,
    throw_err

struct YAMLError <: Exception 
    msg::String
end


struct YAMLMemoryError <: YAMLError
    ctx::String
    problem::String
end


struct YAMLReaderError <: YAMLError
    ctx::String
    problem::String
end


struct YAMLScannerError <: YAMLError
    ctx::String
    problem::String
end


struct YAMLParserError <: YAMLError
    ctx::String
    problem::String
end


function Base.showerror(io::IO, err::YAMLError)
    print(io, "[CONTEXT]: $(err.ctx) | [ERROR]: $(err.problem)")
end


throw_err(::Val{YAML_MEMORY_ERROR}, context::String, problem::String) = 
    throw(YAMLMemoryError(context, problem))
throw_err(::Val{YAML_READER_ERROR}, context::String, problem::String) = 
    throw(YAMLReaderError(context, problem))
throw_err(::Val{YAML_SCANNER_ERROR}, context::String, problem::String) = 
    throw(YAMLScannerError(context, problem))
throw_err(::Val{YAML_PARSER_ERROR}, context::String, problem::String) = 
    throw(YAMLParserError(context, problem))

end # module YAMLErrors