module Raylib

using Raylib_jll
using CEnum

include("enum.jl")
include("color.jl")
include("struct.jl")
include("binding_gen.jl")
include("core.jl")
include("shapes.jl")
include("textures.jl")
include("text.jl")
include("models.jl")
include("audio.jl")

include("binding/binding.jl")
include("easing.jl")
include("raymath.jl")

end
