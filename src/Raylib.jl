module Raylib

using Raylib_jll
using CEnum

include("color.jl")

include("./binding/binding.jl")
using .Binding

end
