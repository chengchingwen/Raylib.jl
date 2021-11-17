using Raylib

const GLSL_VERSION = 330

function build_font(filedata, baseSize, glyphCount, fonttype, padding, packmeth)
    null = convert(Ptr{Cint}, C_NULL)
    glyphs_ptr = Raylib.LoadFontData(pointer(filedata), length(filedata), 16, null, glyphCount, Int(fonttype))
    recs = Ref{Ptr{Raylib.RayRectangle}}()
    atlas = Raylib.GenImageFontAtlas(glyphs_ptr, recs, 95, 16, padding, packmeth)
    recs_ptr = recs[]
    texture = Raylib.LoadTextureFromImage(atlas)
    Raylib.UnloadImage(atlas)

    font = Raylib.RayFont(baseSize, 95, 0, texture, recs_ptr, glyphs_ptr)
    return font
end

function main()
    MAX_FONTS = 8
    screenWidth = 800
    screenHeight = 450

    Raylib.InitWindow(screenWidth, screenHeight, "raylib [text] example - SDF fonts")

    msg = "Signed Distance Fields"

    filedata = Raylib.RayFileData(joinpath(@__DIR__, "resources/anonymous_pro_bold.ttf"))

    basesize = 16
    glyphcount = 95

    default_font = build_font(filedata, basesize, 95, Raylib.FONT_DEFAULT, 4, 0)
    sdf_font = build_font(filedata, basesize, 0, Raylib.FONT_SDF, 0, 0)

    filedata = nothing

    shader = Raylib.LoadShader("", joinpath(@__DIR__, "resources/shaders/glsl$(GLSL_VERSION)/sdf.fs"))
    Raylib.SetTextureFilter(sdf_font.texture, Int(Raylib.TEXTURE_FILTER_BILINEAR))

    font_pos = Raylib.rayvector(40, screenHeight/2 - 50)
    textSize = Raylib.rayvector(0, 0)
    fontSize = 16.0
    current_font = false

    GC.gc()
    Raylib.SetTargetFPS(60)

    while !Raylib.WindowShouldClose()

        fontSize += 8Raylib.GetMouseWheelMove()
        fontSize = max(fontSize, 6)

        current_font = Raylib.IsKeyDown(Raylib.KEY_SPACE)

        textSize = if current_font
            Raylib.MeasureTextEx(sdf_font, msg, fontSize, 0)
        else
            Raylib.MeasureTextEx(default_font, msg, fontSize, 0)
        end

        font_pos = Raylib.rayvector(
            Raylib.GetScreenWidth(),
            Raylib.GetScreenHeight()
        ) ./ 2 .- textSize ./ 2 .+ (0, 80)

        Raylib.BeginDrawing()
        Raylib.ClearBackground(Raylib.RAYWHITE)

        if current_font
            Raylib.BeginShaderMode(shader)
            Raylib.DrawTextEx(sdf_font, msg, font_pos, fontSize, 0, Raylib.BLACK)
            Raylib.EndShaderMode()
            Raylib.DrawTexture(sdf_font.texture, 10, 10, Raylib.BLUE)

            Raylib.DrawText("SDF!", 320, 20, 80, Raylib.RED)
        else
            Raylib.DrawTextEx(default_font, msg, font_pos, fontSize, 0, Raylib.BLACK)
            Raylib.DrawTexture(default_font.texture, 10, 10, Raylib.BLUE)

            Raylib.DrawText("default font", 315, 40, 30, Raylib.GRAY)
        end

        Raylib.DrawText("FONT SIZE: 16.0", Raylib.GetScreenWidth() - 240, 20, 20, Raylib.DARKGRAY)
        Raylib.DrawText("RENDER SIZE: $(fontSize)", Raylib.GetScreenWidth() - 240, 50, 20, Raylib.DARKGRAY)
        Raylib.DrawText("Use MOUSE WHEEL to SCALE TEXT!", Raylib.GetScreenWidth() - 240, 90, 10, Raylib.DARKGRAY)
        Raylib.DrawText("hold space to use sdf font version!", 340, Raylib.GetScreenHeight() - 30, 20, Raylib.MAROON)
        Raylib.EndDrawing()
    end

    Raylib.UnloadFont(default_font)
    Raylib.UnloadFont(sdf_font)
    Raylib.UnloadShader(shader)
    Raylib.CloseWindow()
end
