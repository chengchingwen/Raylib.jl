macro declaration_str(declaration)
    return esc(parse_declaration(declaration, __source__))
end

"type string => (c return type, c argument type, julia argument type [, julia return type])"
const typemap_dict = Dict{String, Any}(
    "void"            => (:Cvoid, :Cvoid, :Nothing),
    "char"            => (:Cchar, :Cchar, :Char),
    "int"             => (:Cint, :Cint, :Integer),
    "long"            => (:Clong, :Clong, :Integer),
    "float"           => (:Cfloat, :Cfloat, :Real),
    "double"          => (:Cdouble, :Cdouble, :Real),
    "unsigned char"   => (:Cuchar, :Cuchar, :UInt8),
    "char **"         => (:(Ptr{Cstring}), :(Ptr{Cstring}), :(Ref{Cstring}), :(Ref{Cstring})),
    "char *"          => (:Cstring, :Cstring, :String, :String),
    "bool"            => (:Cuchar, :Cuchar, :Bool, :Bool),
    "unsigned int"    => (:Cuint, :Cuint, :Integer),
    "Color"           => :RayColor,
    "Camera"          => :RayCamera3D,
    "Camera3D"        => :RayCamera3D,
    "Camera2D"        => :RayCamera2D,
    "Rectangle"       => :RayRectangle,
    "Rectangle **"    => (:(Ptr{Ptr{RayRectangle}}), :(Ptr{Ptr{RayRectangle}}), :(Ref{Ptr{RayRectangle}}), :(Ref{Ptr{RayRectangle}})),
    "Texture"         => :RayTexture,
    "Texture2D"       => :RayTexture,
    "TextureCubemap"  => :RayTexture,
    "RenderTexture"   => :RayRenderTexture,
    "RenderTexture2D" => :RayRenderTexture,
    "NPatchInfo"      => :RayNPatchInfo,
    "Image"           => :RayImage,
    "GlyphInfo"       => :RayGlyphInfo,
    "Font"            => :RayFont,
    "Mesh"            => :RayMesh,
    "Shader"          => :RayShader,
    "MaterialMap"     => :RayMaterialMap,
    "Material"        => :RayMaterial,
    "Transform"       => :RayTransform,
    "BoneInfo"        => :RayBoneInfo,
    "Model"           => :RayModel,
    "ModelAnimation"  => :RayModelAnimation,
    "Ray"             => :Ray,
    "RayCollision"    => :RayCollision,
    "BoundingBox"     => :RayBoundingBox,
    "Wave"            => :RayWave,
    "AudioStream"     => :RayAudioStream,
    "Sound"           => :RaySound,
    "Music"           => :RayMusic,
    "VrDeviceInfo"    => :RayVrDeviceInfo,
    "VrStereoConfig"  => :RayVrStereoConfig,
    "Matrix"          => :RayMatrix,
    "Vector2"         => (:RayVector2, :RayVector2, :(StaticVector{2}), :RayVector2),
    "Vector3"         => (:RayVector3, :RayVector3, :(StaticVector{3}), :RayVector3),
    "Vector4"         => (:RayVector4, :RayVector4, :(StaticVector{4}), :RayVector4),
)

default_get(x::Tuple, i, y=x[3]) = 1 <= i <= length(x) ? x[i] : y
default_get(x, i, _...) = x

function typemap(type, case=:julia)
    global typemap_dict
    caseid = case == :return ? 1 : case == :argument ? 2 : case == :julia ? 3 : 4 #error("unknown case: $case")

    haskey(typemap_dict, type) && return default_get(typemap_dict[type], caseid, nothing)

    ptr_type = strip(x->isspace(x) || isequal('*', x), type)

    type == ptr_type && return nothing
    haskey(typemap_dict, ptr_type) || return nothing

    type_sym = default_get(typemap_dict[ptr_type], caseid)

    if !isabstracttype(eval(type_sym))
        return caseid == 1 ? :(Ptr{$type_sym}) : :(Ref{$type_sym})
    else
        return caseid == 1 ? :(Ptr{<:$type_sym}) : :(Ref{<:$type_sym})
    end
end

jl_type_handler(_, ex) = ex
jl_type_handler(x::Symbol, ex) = jl_type_handler(eval(x), ex)
jl_type_handler(::Type{String}, ex) = :(Base.unsafe_string($ex))

maybe(f, x) = f(x)
maybe(f, ::Nothing) = nothing
maybe(f) = Base.Fix1(maybe, f)

function parse_declaration(declaration, source=nothing)
    global typemap
    declaration = strip(declaration)
    m = match(r"^(const)?([^,]+[* ])([^* ]+)\(([^\)]*)\);\s*(//)?(.*)?", declaration)
    if isnothing(m)
        @debug "not a correct c function declaration, skiped:\n$declaration"
        return nothing
    end

    _, ret_type_s, func_name_s, func_args_s, _, comment = map(maybe(strip), m.captures)

    ret_type = typemap(ret_type_s, :return)
    if isnothing(ret_type)
        @debug "unknown return type <$ret_type_s>, skiped:\n$declaration"
        return nothing
    end

    jl_ret_type = typemap(ret_type_s, :jlret)
    func_name = Symbol(func_name_s)

    if func_args_s == "void"
        c_args = Expr[]
        jl_args = Expr[]
    else
        arg_num = count(isequal(','), func_args_s) + 1
        args_m = collect(eachmatch(r" *(const)?([^,]+[* ])([^ *,]+)", func_args_s))
        if arg_num != length(args_m)
            @debug "problem while parsing function args <$func_args_s>, skiped:\n$declaration"
            return nothing
        end

        c_args = Vector{Expr}(undef, arg_num)
        jl_args = Vector{Expr}(undef, arg_num)
        for i = 1:arg_num
            _, arg_type_s, arg_name_s = map(maybe(strip), args_m[i].captures)
            arg_type = typemap(arg_type_s, :argument)
            if isnothing(arg_type)
                @debug "unknown $i-th argument type <$arg_type_s>, skiped:\n$declaration"
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
