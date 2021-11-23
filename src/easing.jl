const easings_api = Raylib.Binding.parse(
    joinpath(dirname(@__DIR__), "api_reference/easings_api.xml")
)

for func in easings_api[:raylibAPI][:Functions][:Function]
    name = Symbol(func[:attr].name)
    if isdefined(@__MODULE__, name)
        @info "duplicat $name from $lib. skip"
        continue
    end

    expr = Raylib.Binding.gen_func(func)
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
