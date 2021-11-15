using Raylib
using Documenter

DocMeta.setdocmeta!(Raylib, :DocTestSetup, :(using Raylib); recursive=true)

makedocs(;
    modules=[Raylib],
    authors="chengchingwen <adgjl5645@hotmail.com> and contributors",
    repo="https://github.com/chengchingwen/Raylib.jl/blob/{commit}{path}#{line}",
    sitename="Raylib.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://chengchingwen.github.io/Raylib.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/chengchingwen/Raylib.jl",
    devbranch="main",
)
