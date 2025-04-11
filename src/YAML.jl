module YAML

using LibYAML

export parse_yaml_str


"""
    parse_yaml_str(yaml_str::String)::Vector{Dict{Any, Any}}

Returns a sequence of documents parsed from YAML string given.
Each dictionary in a vector represents a separate parsed document.
"""
function parse_yaml_str(yaml_str::String)
    parser = Ref{yaml_parser_t}()
    docs = Dict{Any, Any}[]

    success = yaml_parser_initialize(parser)
    success == 0 && throw_yaml_err(
        parser[].error,
        parser[].context, 
        parser[].context_mark,
        parser[].problem,
        parser[].problem_mark,
    )
    yaml_parser_set_input_string(parser, pointer(yaml_str), sizeof(yaml_str))

    while true
        doc = Ref{yaml_document_t}()

        success = yaml_parser_load(parser, doc)
        success == 0 && throw_yaml_err(
            parser[].error,
            parser[].context, 
            parser[].context_mark,
            parser[].problem,
            parser[].problem_mark,
        )

        root = yaml_document_get_root_node(doc) 
        root == C_NULL && break
        push!(docs, parse(doc, root))

        yaml_document_delete(doc)
    end

    yaml_parser_delete(parser)

    return docs
end


@inline function parse(doc::Ref{yaml_document_t}, node_ptr::Ptr{yaml_node_t})
    node = unsafe_load(node_ptr)
    node_type = node.type
    scalar = node.data.scalar
    sequence = node.data.sequence
    mapping = node.data.mapping

    if node_type == YAML_SCALAR_NODE
        return parse_scalar(doc, scalar)
    elseif node_type == YAML_SEQUENCE_NODE
        return parse_sequence(doc, sequence)
    elseif node_type == YAML_MAPPING_NODE
        return parse_mapping(doc, mapping)
    else
        throw(YAMLError("Unsupported node type"))
    end
end


@inline parse_scalar(doc::Ref{yaml_document_t}, scalar) = unsafe_string(scalar.value)

@inline function parse_sequence(doc::Ref{yaml_document_t}, sequence)
    items = sequence.items
    len = get_c_arr_size(items.start, items.top, sizeof(Cuint))

    items_ptr = items.start
    yaml_arr = Vector{Any}(undef, len)
    @inbounds for i in eachindex(yaml_arr)
        idx_ptr = Ptr{Cuint}(items_ptr + (i - 1) * sizeof(Cuint))
        idx = unsafe_load(idx_ptr)
        yaml_arr[i] = parse(doc, yaml_document_get_node(doc, idx))
    end

    return yaml_arr
end


@inline function parse_mapping(doc::Ref{yaml_document_t}, mapping)
    pairs = mapping.pairs
    len = get_c_arr_size(pairs.start, pairs.top, sizeof(yaml_node_pair_t))

    pairs_ptr = pairs.start
    yaml_dict = Dict{Any, Any}()
    @inbounds for i in 1:len
        pair_ptr = Ptr{yaml_node_pair_t}(pairs_ptr + (i - 1) * sizeof(yaml_node_pair_t))
        pair = unsafe_load(pair_ptr)
        key = parse(doc, yaml_document_get_node(doc, pair.key))
        val = parse(doc, yaml_document_get_node(doc, pair.value))
        yaml_dict[key] = val
    end

    return yaml_dict
end

@inline get_c_arr_size(start, top, size) = (top - start) ÷ size


include("errors.jl")
using .YAMLErrors

end # module YAML
