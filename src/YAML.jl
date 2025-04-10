module YAML

using LibYAML

export parse_yaml_str


function parse_yaml_str(yaml_str::String)
    parser = Ref{yaml_parser_t}()
    doc = Ref{yaml_document_t}()

    success = yaml_parser_initialize(parser)
    success == 0 && throw_err(
        Val(parser[].error), 
        unsafe_string(parser[].context), 
        unsafe_string(parser[].problem),
    )
    yaml_parser_set_input_string(parser, pointer(yaml_str), sizeof(yaml_str))

    success = yaml_parser_load(parser, doc)
    success == 0 && throw_err(
        Val(parser[].error), 
        unsafe_string(parser[].context), 
        unsafe_string(parser[].problem),
    )

    root = yaml_document_get_root_node(doc) 
    result = convert(doc[], root)

    yaml_document_delete(doc)
    yaml_parser_delete(parser)

    return result
end


@inline function convert(doc::yaml_document_t, node_ptr::Ptr{yaml_node_t})
    node_type = unsafe_load(node_ptr).type
    return convert(Val(node_type), doc, node_ptr)
end


@inline convert(
    ::Val{YAML_SCALAR_NODE}, 
    doc::yaml_document_t, 
    node_ptr::Ptr{yaml_node_t},
) = unsafe_string(unsafe_load(node_ptr).data.scalar.value)

@inline function convert(
    ::Val{YAML_SEQUENCE_NODE}, 
    doc::yaml_document_t, 
    node_ptr::Ptr{yaml_node_t},
)
    sequence = unsafe_load(node_ptr).data.sequence.items
    len = get_c_arr_size(sequence.start, sequence.top, sizeof(Cuint))
    items = unsafe_wrap(Array, sequence.start, len)
    return [convert(doc, yaml_document_get_node(Ref(doc), i)) for i in items]
end


@inline function convert(
    ::Val{YAML_MAPPING_NODE}, 
    doc::yaml_document_t, 
    node_ptr::Ptr{yaml_node_t},
)
    mapping = unsafe_load(node_ptr).data.mapping.pairs
    len = get_c_arr_size(mapping.start, mapping.top, sizeof(yaml_node_pair_t))
    pairs = unsafe_wrap(Array, mapping.start, len)
    return Dict(
        convert(doc, yaml_document_get_node(Ref(doc), p.key)) =>
        convert(doc, yaml_document_get_node(Ref(doc), p.value))
        for p in pairs
    )
end


@inline convert(::Val{T}, ::yaml_document_t, ::Ptr{yaml_node_t}) where T = 
    throw(YAMLError("Unsupported node type: $T"))

@inline get_c_arr_size(start, top, size) = (top - start) ÷ size


include("errors.jl")
using .YAMLErrors

end # module YAML
