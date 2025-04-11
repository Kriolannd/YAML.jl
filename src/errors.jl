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
    ctx_mark::Vector{Int64}
    problem::String
    prob_mark::Vector{Int64}
end


struct YAMLReaderError <: AbstractYAMLError
    ctx::String
    ctx_mark::Vector{Int64}
    problem::String
    prob_mark::Vector{Int64}
end


struct YAMLScannerError <: AbstractYAMLError
    ctx::String
    ctx_mark::Vector{Int64}
    problem::String
    prob_mark::Vector{Int64}
end


struct YAMLParserError <: AbstractYAMLError
    ctx::String
    ctx_mark::Vector{Int64}
    problem::String
    prob_mark::Vector{Int64}
end


function Base.showerror(io::IO, err::AbstractYAMLError)
    if isempty(err.ctx)
        print(io, "[ERROR]: $(err.problem) around (line = $(err.prob_mark[1]), \
                    column = $(err.prob_mark[2]))")
    else
        print(io, "[CONTEXT]: $(err.ctx) around (line = $(err.ctx_mark[1]), \
                    column = $(err.ctx_mark[2])) | [ERROR]: $(err.problem) around (line = \
                    $(err.prob_mark[1]), column = $(err.prob_mark[2]))")
    end
end


function Base.showerror(io::IO, err::YAMLError)
    print(io, err.msg)
end


function throw_yaml_err(
    type::yaml_error_type_e, 
    context, 
    context_mark, 
    problem, 
    problem_mark,
)
    ctx = context == C_NULL ? "" : unsafe_string(context)
    prob = unsafe_string(problem)
    if !(context_mark == C_NULL) 
        ctx_mark_l = Int64(context_mark.line)
        ctx_mark_c = Int64(context_mark.column)
        ctx_mark = [ctx_mark_l, ctx_mark_c]
    else
        ctx_mark = Int64[]
    end
    prob_mark_l = Int64(problem_mark.line)
    prob_mark_c = Int64(problem_mark.column)
    prob_mark = [prob_mark_l, prob_mark_c]

    if type == YAML_MEMORY_ERROR
        throw(YAMLMemoryError(ctx, ctx_mark, prob, prob_mark))
    elseif type == YAML_READER_ERROR
        throw(YAMLReaderError(ctx, ctx_mark, prob, prob_mark))
    elseif type == YAML_SCANNER_ERROR
        throw(YAMLScannerError(ctx, ctx_mark, prob, prob_mark))
    elseif type == YAML_PARSER_ERROR
        throw(YAMLParserError(ctx, ctx_mark, prob, prob_mark))
    end

    return nothing
end

end # module YAMLErrors