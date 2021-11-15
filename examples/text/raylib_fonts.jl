using Raylib
using Raylib: RayFont, RayVector2, rayvector,
    MAROON, ORANGE, DARKGREEN, DARKBLUE, DARKPURPLE, LIME, GOLD, RED 


function main()
    MAX_FONTS = 8
    screenWidth = 800
    screenHeight = 450

    Raylib.InitWindow(screenWidth, screenHeight, "raylib [text] example - raylib fonts")

    # NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    font_files = [
        "resources/fonts/alagard.png",      
        "resources/fonts/pixelplay.png",    
        "resources/fonts/mecha.png",        
        "resources/fonts/setback.png",      
        "resources/fonts/romulus.png",      
        "resources/fonts/pixantiqua.png",   
        "resources/fonts/alpha_beta.png", 
        "resources/fonts/jupiter_crash.png",
    ]
    
    fonts = map(font_files) do file
        Raylib.LoadFont(joinpath(@__DIR__, file))
    end
    
    messages = [
        "ALAGARD FONT designed by Hewett Tsoi",
        "PIXELPLAY FONT designed by Aleksander Shevchuk",
        "MECHA FONT designed by Captain Falcon",
        "SETBACK FONT designed by Brian Kent (AEnigma)",
        "ROMULUS FONT designed by Hewett Tsoi",
        "PIXANTIQUA FONT designed by Gerhard Grossmann",
        "ALPHA_BETA FONT designed by Brian Kent (AEnigma)",
        "JUPITER_CRASH FONT designed by Brian Kent (AEnigma)",
    ]

    spacings = [2, 4, 8, 4, 3, 4, 4, 1]

    positions = map(1:MAX_FONTS) do i
        rayvector(
            screenWidth/2 - Raylib.MeasureTextEx(fonts[i], messages[i], 2*fonts[i].baseSize, spacings[i])[1]/2,
            60 + fonts[i].baseSize + 45(i-1)
        )
    end

    positions[4] = positions[4] .+ (0, 8)
    positions[5] = positions[5] .+ (0, 2)
    positions[8] = positions[8] .- (0, 8)


    colors = [ MAROON, ORANGE, DARKGREEN, DARKBLUE, DARKPURPLE, LIME, GOLD, RED ]

    Raylib.SetTargetFPS(60)

    while !Raylib.WindowShouldClose()
        Raylib.BeginDrawing()
        Raylib.ClearBackground(Raylib.RAYWHITE)

        Raylib.DrawText("free fonts included with raylib", 250, 20, 20, Raylib.DARKGRAY)
        Raylib.DrawLine(200, 50, 590, 50, Raylib.DARKGRAY)
        
        for i = 1:MAX_FONTS
            Raylib.DrawTextEx(
                fonts[i], messages[i], positions[i], 2fonts[i].baseSize, spacings[i], colors[i]
            )
        end
        
        Raylib.EndDrawing()
    end

    foreach(Raylib.UnloadFont, fonts)
    Raylib.CloseWindow()
end

