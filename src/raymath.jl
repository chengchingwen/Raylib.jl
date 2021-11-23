const raymath_api = Raylib.Binding.parse(
    joinpath(dirname(@__DIR__), "api_reference/raymath_api.xml")
)

for cstruct in raymath_api[:raylibAPI][:Structs][:Struct]
    name = Symbol("Ray$(cstruct[:attr].name)")
    if isdefined(@__MODULE__, name)
        @info "duplicate $name from raymath. skip"
        continue
    end

    expr = Raylib.Binding.gen_struct(cstruct)
    if isnothing(expr)
        @info "failed to generate struct: $cstruct"
    else
        @eval $expr
    end
end

for func in raymath_api[:raylibAPI][:Functions][:Function]
    name = Symbol(func[:attr].name)
    if isdefined(@__MODULE__, name)
        @info "duplicat $name from raymath. skip"
        continue
    end

    expr = Raylib.Binding.gen_func(func)
    if isnothing(expr)
        @info "failed to generate function: $func"
    else
        try
            @eval $expr
        catch
            @show "raymath", expr
        end
    end
end
