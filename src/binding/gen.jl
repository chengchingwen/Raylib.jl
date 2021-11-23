using ..Raylib: RayVector2, RayVector3, RayVector4, RayMatrix

maybe(f, x) = f(x)
maybe(f, ::Nothing) = nothing
maybe(f) = Base.Fix1(maybe, f)

function nested_X(X, T, n, abs=false)
    P = T
    for i = 1:n
        if abs
            P = Expr(:<:, P)
        end
        P = Expr(:curly, X, P)
    end
    return P
end
nested_ptr(T, n, abs=false) = nested_X(:Ptr, T, n, abs)
nested_refptr(T, n, abs=false) = n >= 1 ? nested_X(:Ref, nested_X(:Ptr, T, n-1, abs), 1, abs) : T

function parse_type(type_s)
    m = match(r"(const )?([^\*]+)(\*+)?", type_s)
    isnothing(m) && return nothing

    cst, type_name, stars = map(maybe(strip), m.captures)
    iscst = !isnothing(cst)
    nptr = maybe(length, stars)

    return iscst, type_name, nptr
end

get_type(x::Tuple, n, i) = i <= length(x) ? x[i] : nothing
get_type(x, n, i) = x
get_type(x::Function, n, i) = x(n, i)

function x_typemap(i, iscst, type_name, ::Nothing)
    global typemap_dict

    T = maybe(get(typemap_dict, type_name, nothing)) do x
        get_type(x, type_name, i)
    end

    return T
end

function x_typemap(i, iscst, type_name, nptr)
    global typemap_dict, special_ptr

    if haskey(special_ptr, type_name)
        type_name, nptr = special_ptr[type_name](type_name, nptr)
    end

    T = x_typemap(i, iscst, type_name, nothing)
    isnothing(T) && return nothing

    isabs = isabstracttype(eval(T))
    return isone(i) ? nested_ptr(T, nptr, isabs) : nested_refptr(T, nptr, isabs)
end
c_typemap(iscst, type_name, nptr) = x_typemap(1, iscst, type_name, nptr)
jl_typemap(iscst, type_name, nptr) = x_typemap(2, iscst, type_name, nptr)

const special_ptr = Dict{String, Any}(
    "char"   => (name, n) -> ("$name *", n-1)
)

const typemap_dict = Dict{String, Any}(
    "void"               => (:Cvoid, :Nothing),
    "char"               => (:Cchar, :Char),
    "char *"             => (:Cstring, :String),
    "int"                => (:Cint, :Integer),
    "long"               => (:Clong, :Integer),
    "long long"          => (:Clonglong, :Integer),
    "short"              => (:Cshort, :Integer),
    "float"              => (:Cfloat, :Real),
    "double"             => (:Cdouble, :Real),
    "unsigned char"      => (:Cuchar, :UInt8),
    "unsigned int"       => (:Cuint, :Integer),
    "unsigned long"      => (:Culong, :Integer),
    "unsigned long long" => (:Culonglong, :Integer),
    "unsigned short"     => (:Cushort, :Integer),
    "bool"               => (:Cuchar, :Bool, :Bool),

    "Vector2" => :RayVector2,
    "Vector3" => :RayVector3,
    "Vector4" => :RayVector4,
    "Matrix" => :RayMatrix,
    "Quaternion" => :RayVector4,
    "float3" => :(NTuple{3, Cfloat}),
    "float16" => :(NTuple{16, Cfloat}),
)

function gen_enum(def)
    attr = def[:attr]
    name = Symbol(attr.name)
    vcount = Base.parse(Int, attr.valueCount)
    values = def[:Value]

    values_ex = map(values) do v
        i = tryparse(Int, v.integer)
        n = Symbol(v.name)
        isnothing(i) ?
            :($n) :
            :($n = $i)
    end
    body = Expr(:block, values_ex...)

    return Expr(:macrocall, Symbol("@cenum"),  nothing, name, body)
end

function typeassert_expr(name, type)
    return isnothing(type) ? name : Expr(:(::), name, type)
end

function gen_struct(def)
    attr = def[:attr]
    name = attr.name
    fcount = Base.parse(Int, attr.fieldCount)
    fields = def[:Field]

    fields_ex = map(fields) do f
        typeassert_expr(Symbol(f.name), c_typemap(parse_type(f.type)...))
    end
    body = Expr(:block, fields_ex...)
    name_ex = Symbol("Ray$name")
    Expr(:struct, false, name_ex, body)
end

jl_type_handler(_, ex) = ex
jl_type_handler(x::Symbol, ex) = jl_type_handler(eval(x), ex)
jl_type_handler(::Type{String}, ex) = :(Base.unsafe_string($ex))

function gen_func(def)
    attr = def[:attr]
    name = Symbol(attr.name)
    rT = attr.retType
    pcount = Base.parse(Int, attr.paramCount)
    params = iszero(pcount) ? () : def[:Param]

    c_param_ex = map(params) do p
      typeassert_expr(Symbol(p.name), c_typemap(parse_type(p.type)...))
    end
    c_rT = c_typemap(parse_type(rT)...)

    jl_param_ex = map(params) do p
      typeassert_expr(Symbol(p.name), jl_typemap(parse_type(p.type)...))
    end
    jl_rT = jl_typemap(parse_type(rT)...)

    c_sig = typeassert_expr(
        Expr(
            :call,
            Expr(:., :libraylib, QuoteNode(name)),
            c_param_ex...
        ),
        c_rT
    )
    call_ex = Expr(:macrocall, Symbol("@ccall"),  nothing, c_sig)

    jl_sig = typeassert_expr(
        Expr(
            :call, name,
            jl_param_ex...
        ),
        jl_rT
    )
    func_body = Expr(:return, jl_type_handler(jl_rT, call_ex))
    func_def = Expr(:function, jl_sig, func_body)
    return quote $func_def end
end
