module Raylib

using Raylib_jll
using CEnum

include("color.jl")

include("./binding/binding3.jl")
using .Binding

end
