using Raylib


function main()
    screenWidth = 800
    screenHeight = 450

    Raylib.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image loading")

    image = Raylib.LoadImage(joinpath(@__DIR__, "resources/raylib_logo.png"))
    texture = Raylib.LoadTextureFromImage(image)
    Raylib.UnloadImage(image)

    while !Raylib.WindowShouldClose()        
        Raylib.BeginDrawing()
        Raylib.ClearBackground(Raylib.RAYWHITE)
        Raylib.DrawTexture(texture, fld(screenWidth - texture.width, 2), fld(screenHeight - texture.height, 2), Raylib.WHITE)
        Raylib.DrawText("this IS a texture loaded from an image!", 300, 370, 10, Raylib.GRAY)
        Raylib.EndDrawing()
    end

    Raylib.UnloadTexture(texture)
    Raylib.CloseWindow()
end

