module Binding

using CEnum

let
    parse_xml(f) = open(f) do io
        function parse_data(pairs)
            return NamedTuple(
                Pair(Symbol(m.captures[1]), m.captures[2]) for m in eachmatch(r"([^ ]+)=\"([^\"]*)\"", pairs)
            )
        end
        stack = Int[]
        char_stream = Char[]
        records = Dict{Symbol, Any}[Dict()]
        sizehint!(stack, 20)
        sizehint!(char_stream, 200)

        idx = 0
        push_c = false
        while !eof(io)
            idx += 1
            c = read(io, Char)
            push!(char_stream, c)

            if c == '"' # avoid stacking </> in string
                char_stream[last(stack)] == '"' ? pop!(stack) : push!(stack, idx)
            elseif c == '<' # mark start position
                push_c = true
                push!(stack, idx)
            elseif c == '>'
                push_c = false
                pidx = pop!(stack)
                content = String(@view(char_stream[pidx:idx]))
                idx = pidx-1 # reset idx
                resize!(char_stream, idx) # remove content from stream

                m = match(r"</([^ ]+)>", content)
                if !isnothing(m)
                    label = m.captures[]
                    rec = pop!(records)
                    if isempty(records)
                        push!(rec)
                    end
                    continue
                end

                m = match(r"<([^ ]+) (.+) />", content)
                if !isnothing(m)
                    label, pairs = m.captures
                    data = parse_data(pairs)
                    push!(get!(last(records), Symbol(label), typeof(data)[]), data)
                    continue
                end

                m = match(r"<\?.*\?>", content)
                if !isnothing(m)
                    @debug "ignore xml header"
                    continue
                end

                m = match(r"<([^ ]+)( .+)?>", content)
                if !isnothing(m)
                    label, pairs = m.captures
                    sym = Symbol(label)
                    rr = last(records)

                    record = Dict{Symbol, Any}()
                    if haskey(rr, sym)
                        rlist = rr[sym]
                        if rlist isa Vector
                            push!(rlist, record)
                        else
                            rr[sym] = [rlist, record]
                        end
                    else
                        rr[sym] = record
                    end
                    push!(records, record)

                    if !isnothing(pairs)
                        record[:attr] = parse_data(pairs)
                    end

                    continue
                end

                @debug "cannnot parse content: $content"
            else
                if !push_c
                    pop!(char_stream)
                    idx -= 1
                end
            end
        end
        @assert all(isempty, (stack, char_stream))
        return records[]
    end

    builder = function ()
        special_ptr = Dict{String, Any}(
            "char"   => (name, n) -> ("$name *", n-1)
        )
        typemap_dict = Dict{String, Any}(
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
            "float3"             => :(NTuple{3, Cfloat}),
            "float16"             => :(NTuple{16, Cfloat}),
            "Color"              => :RayColor,
            "Camera"             => :RayCamera3D,
            "Camera3D"           => :RayCamera3D,
            "Camera2D"           => :RayCamera2D,
            "Rectangle"          => :RayRectangle,
            "Texture"            => :RayTexture,
            "Texture2D"          => :RayTexture,
            "TextureCubemap"     => :RayTexture,
            "RenderTexture"      => :RayRenderTexture,
            "RenderTexture2D"    => :RayRenderTexture,
            "NPatchInfo"         => :RayNPatchInfo,
            "Image"              => :RayImage,
            "GlyphInfo"          => :RayGlyphInfo,
            "Font"               => :RayFont,
            "Mesh"               => :RayMesh,
            "Shader"             => :RayShader,
            "MaterialMap"        => :RayMaterialMap,
            "Material"           => :RayMaterial,
            "Transform"          => :RayTransform,
            "BoneInfo"           => :RayBoneInfo,
            "Model"              => :RayModel,
            "ModelAnimation"     => :RayModelAnimation,
            "Ray"                => :RayRay,
            "RayCollision"       => :RayRayCollision,
            "BoundingBox"        => :RayBoundingBox,
            "Wave"               => :RayWave,
            "AudioStream"        => :RayAudioStream,
            "Sound"              => :RaySound,
            "Music"              => :RayMusic,
            "VrDeviceInfo"       => :RayVrDeviceInfo,
            "VrStereoConfig"     => :RayVrStereoConfig,
            "Matrix"             => :RayMatrix,
            "Vector2"            => :RayVector2,
            "Vector3"            => :RayVector3,
            "Vector4"            => :RayVector4,
            "Quaternion"         => :RayVector4,
            "PhysicsBodyData"    => :RayPhysicsBodyData,
            "PhysicsBody"        => :(Ptr{RayPhysicsBodyData}),
            "MemPool"            => :RayMemPool,
        )
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
            T = maybe(get(typemap_dict, type_name, nothing)) do x
                get_type(x, type_name, i)
            end

            return T
        end

        function x_typemap(i, iscst, type_name, nptr)
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
        jlret_typemap(iscst, type_name, nptr) = x_typemap(3, iscst, type_name, nptr)

        function gen_enum(def)
            attr = def[:attr]
            name = Symbol(attr.name)
            vcount = Base.parse(Int, attr.valueCount)
            iszero(vcount) && return nothing
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

        function gen_func(def, use_desc=true)
            attr = def[:attr]
            name = Symbol(attr.name)
            rT = attr.retType
            desc = use_desc ? attr.desc : ""
            pcount = Base.parse(Int, attr.paramCount)
            params = iszero(pcount) ? () : def[:Param]

            c_param_ex = if iszero(pcount)
                map(params) do p
                    typeassert_expr(Symbol(p.name), c_typemap(parse_type(p.type)...))
                end
            else
                Expr[]
            end
            c_rT = c_typemap(parse_type(rT)...)

            jl_param_ex = if iszero(pcount)
                map(params) do p
                    typeassert_expr(Symbol(p.name), jl_typemap(parse_type(p.type)...))
                end
            else
                Expr[]
            end
            jl_rT = jlret_typemap(parse_type(rT)...)

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

            docstring = "    $func_def\n\n$desc"
            return quote
                Core.@doc $docstring
                $func_def
            end
        end

        return gen_enum, gen_struct, gen_func
    end

    gen_enum, gen_struct, gen_func = builder()

    apis = map(
        f->joinpath(@__DIR__, "../../api_reference/", f),
        ("raylib_api.xml", "raygui_api.xml",
         "raymath_api.xml", "physac_api.xml",
         "easings_api.xml", "rmem_api.xml")
    )

    xmls = Dict(
        map(apis) do api_file
          api_file=>parse_xml(api_file)
        end
    )


    for api in apis
        xml = xmls[api]
        lib = split(basename(api), '_')[1]

        defs = xml[:raylibAPI]
        enums = defs[:Enums]
        n_enum = Base.parse(Int, enums[:attr].count)
        if !iszero(n_enum)
            for enum in enums[:Enum]
                name = Symbol(enum[:attr].name)
                if isdefined(@__MODULE__, name)
                    @info "deplicate $name from $lib. skip"
                    continue
                end
                expr = gen_enum(enum)
                if isnothing(expr)
                    @info "failed to generate enum: $enum"
                else
                    @eval $expr
                end
            end
        end

        structs = defs[:Structs]
        n_struct = Base.parse(Int, structs[:attr].count)
        if !iszero(n_struct)
            for cstruct in structs[:Struct]
                name = Symbol("Ray$(cstruct[:attr].name)")
                if isdefined(@__MODULE__, name)
                    @info "duplicate $name from $lib. skip"
                    continue
                end
                expr = gen_struct(cstruct)
                if isnothing(expr)
                    @info "failed to generate struct: $cstruct"
                else
                    @eval $expr
                end
            end
        end

        funcs = defs[:Functions]
        n_func = Base.parse(Int, funcs[:attr].count)
        if !iszero(n_func)
            for func in funcs[:Function]
                name = Symbol(func[:attr].name)
                if isdefined(@__MODULE__, name)
                    @info "duplicat $name from $lib. skip"
                    continue
                end
                expr = gen_func(func)
                if isnothing(expr)
                    @info "failed to generate function: $func"
                else
                    try
                        @eval $expr
                    catch
                        @show lib, expr
                    end
                end
            end
        end
    end

end

end
