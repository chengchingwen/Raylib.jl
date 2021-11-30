module Raylib

using Raylib_jll
using CEnum

include("color.jl")
include("struct.jl")

include("binding/binding.jl")
using .Binding

include("core.jl")
include("shapes.jl")

include("easing.jl")

end
