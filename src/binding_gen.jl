macro declaration_str(declaration)
    return esc(parse_declaration(declaration, __source__))
end

"type string => (c return type, c argument type, julia argument type [, julia return type])"
const typemap_dict = Dict{String, Any}(
    "void"            => (Cvoid, Cvoid, Nothing),
    "int"             => (Cint, Cint, Integer),
    "long"            => (Clong, Clong, Integer),
    "float"           => (Cfloat, Cfloat, Real),
    "double"          => (Cdouble, Cdouble, Real),
    "const char *"    => (Cstring, Cstring, String, String),
    "char *"          => (Cstring, Cstring, String, String),
    "bool"            => (Cint, Cint, Bool, Bool),
    "unsigned int"    => (Cuint, Cuint, Integer),
    "Color"           => (RayColor, RayColor, RayColor),
    "Camera"          => (RayCamera3D, RayCamera3D, RayCamera3D),
    "Camera3D"        => (RayCamera3D, RayCamera3D, RayCamera3D),
    "Camera2D"        => (RayCamera2D, RayCamera2D, RayCamera2D),
    "Vector2"         => ((NTuple{2, Cfloat}), (NTuple{2, Cfloat}), RayVector2),
    "Vector3"         => ((NTuple{3, Cfloat}), (NTuple{3, Cfloat}), RayVector3),
    "Vector4"         => ((NTuple{4, Cfloat}), (NTuple{4, Cfloat}), RayVector4),
)

default_get(x::Tuple, i, y=nothing) = 1 <= i <= length(x) ? x[i] : y

function typemap(type, case=:julia)
    global typemap_dict
    caseid = case == :return ? 1 : case == :argument ? 2 : case == :julia ? 3 : 4 #error("unknown case: $case")

    haskey(typemap_dict, type) && return default_get(typemap_dict[type], caseid)

    ptr_type = strip(x->isspace(x) || isequal('*', x), type)

    type == ptr_type && return nothing
    haskey(typemap_dict, ptr_type) || return nothing

    type_sym = default_get(typemap_dict[ptr_type], caseid, typemap_dict[ptr_type][3])
    return caseid == 1 ? :(Ptr{$type_sym}) : :(Ref{$type_sym})
end

jl_type_handler(x, ex) = ex
jl_type_handler(::Type{String}, ex) = :(Base.unsafe_string($ex))

function parse_declaration(declaration, source=nothing)
    global typemap
    declaration = strip(declaration)
    m = match(r"^([^,]+[* ])([^* ]+)\(([^\)]*)\);\s*//(.*)", declaration)
    if isnothing(m)
        @info "not a correct c function declaration, skiped:\n$declaration"
        return nothing
    end

    ret_type_s, func_name_s, func_args_s, comment = map(strip, m.captures)

    ret_type = typemap(ret_type_s, :return)
    if isnothing(ret_type)
        @info "unknown return type <$ret_type_s>, skiped:\n$declaration"
        return nothing
    end

    jl_ret_type = typemap(ret_type_s, :jlret)
    func_name = Symbol(func_name_s)

    if func_args_s == "void"
        c_args = Expr[]
        jl_args = Expr[]
    else
        arg_num = count(isequal(','), func_args_s) + 1
        args_m = collect(eachmatch(r"([^,]+[* ])([^ *,]+)", func_args_s))
        if arg_num != length(args_m)
            @info "problem while parsing function args <$func_args_s>, skiped:\n$declaration"
            return nothing
        end

        c_args = Vector{Expr}(undef, arg_num)
        jl_args = Vector{Expr}(undef, arg_num)
        for i = 1:arg_num
            arg_type_s, arg_name_s = map(strip, args_m[i].captures)
            arg_type = typemap(arg_type_s, :argument)
            if isnothing(arg_type)
                @info "unknown $i-th argument type <$arg_type_s>, skiped:\n$declaration"
                return nothing
            end

            jl_arg_type = typemap(arg_type_s)
            arg_name = Symbol(arg_name_s)
            c_args[i] = :($(arg_name)::$(arg_type))
            jl_args[i] = :($(arg_name)::$(jl_arg_type))
        end
    end

    csig = Expr(
        :(::), Expr(
            :call,
            Expr(:., :libraylib, QuoteNode(func_name)),
            c_args...
        ),
        ret_type
    )
    call_ex = Expr(:macrocall, Symbol("@ccall"),  source, csig)

    if !isnothing(jl_ret_type)
        sig = Expr(
            :(::), Expr(
                :call, func_name,
                jl_args...
            ),
            jl_ret_type
        )
        func_body = quote return $(jl_type_handler(jl_ret_type, call_ex)) end
    else
        sig = Expr(
            :call, func_name,
            jl_args...
        )
        func_body = quote return $call_ex end
    end

    docstring = "    $sig\n    $csig\n\n$comment"
    func_def = Expr(:function, sig, func_body)

    body = quote
        Core.@doc $docstring
        $func_def
    end

    return body
end
