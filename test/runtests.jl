using Raylib
using Test

@testset "Raylib.jl" begin
    include("core.jl")
    include("xml.jl")
    include("easing.jl")
end
