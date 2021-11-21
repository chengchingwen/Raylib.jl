@testset "parse xml" begin
    struct_root = Raylib.parse(joinpath(@__DIR__, "xml/struct.xml"))
    @test struct_root == Dict{Symbol, Any}(
        :raylibAPI => Dict{Symbol, Any}(
            :Structs => Dict{Symbol, Any}(
                :attr => (count = "8",),
                :Struct => Dict{Symbol, Any}(
                    :Field => NamedTuple{
                        (:type, :name, :desc),
                        Tuple{SubString{String}, SubString{String}, SubString{String}}
                    }[
                        (type = "float", name = "x", desc = ""),
                        (type = "float", name = "y", desc = "")
                    ],
                    :attr => (name = "Vector2", fieldCount = "2", desc = "")
                )
            )
        )
    )

    enum_root = Raylib.parse(joinpath(@__DIR__, "xml/enum.xml"))
    @test enum_root == Dict{Symbol, Any}(
        :raylibAPI => Dict{Symbol, Any}(
            :Enums => Dict{Symbol, Any}(
                :Enum => Dict{Symbol, Any}[
                    Dict(:attr => (name = "Vector2", valueCount = "0", desc = "")),
                    Dict(
                        :attr => (name = "GuiControlState", valueCount = "4", desc = ""),
                        :Value => NamedTuple{
                            (:name, :integer, :desc),
                            Tuple{SubString{String}, SubString{String}, SubString{String}}
                        }[
                            (name = "GUI_STATE_NORMAL", integer = "0", desc = ""),
                            (name = "GUI_STATE_FOCUSED", integer = "1", desc = ""),
                            (name = "GUI_STATE_PRESSED", integer = "2", desc = ""),
                            (name = "GUI_STATE_DISABLED", integer = "3", desc = "")
                        ]
                    )
                ],
                :attr => (count = "20",)
            )
        )
    )

    func_root = Raylib.parse(joinpath(@__DIR__, "xml/function.xml"))
    @test func_root == Dict{Symbol, Any}(
        :raylibAPI => Dict{Symbol, Any}(
            :Functions => Dict{Symbol, Any}(
                :attr => (count = "487",),
                :Function => Dict{Symbol, Any}[
                    Dict(
                        :attr => (name = "InitWindow", retType = "void", paramCount = "3", desc = "Initialize window and OpenGL context"),
                        :Param => NamedTuple{
                            (:type, :name, :desc),
                            Tuple{SubString{String}, SubString{String}, SubString{String}}
                        }[
                            (type = "int", name = "width", desc = ""),
                            (type = "int", name = "height", desc = ""),
                            (type = "const char *", name = "title", desc = "")
                        ]
                    ),
                    Dict(:attr => (name = "WindowShouldClose", retType = "bool", paramCount = "0", desc = "Check if KEY_ESCAPE pressed or Close icon pressed")),
                    Dict(:attr => (name = "CloseWindow", retType = "void", paramCount = "0", desc = "Close window and unload OpenGL context")),
                    Dict(:attr => (name = "IsWindowReady", retType = "bool", paramCount = "0", desc = "Check if window has been initialized successfully"))
                ]
            )
        )
    )
end
