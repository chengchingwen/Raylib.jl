using Raylib


function main()
    screenWidth = 800
    screenHeight = 450

    Raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - drop files")

    Raylib.SetTargetFPS(60)

    droppedFiles = Vector{String}()
    
    while !Raylib.WindowShouldClose()

        if Raylib.IsFileDropped()
            droppedFiles = Raylib.GetDroppedFiles()
        end

        Raylib.BeginDrawing()
        Raylib.ClearBackground(Raylib.RAYWHITE)
        if iszero(length(droppedFiles))
            Raylib.DrawText("Drop your files to this window!", 100, 40, 20, Raylib.DARKGRAY)
        else
            Raylib.DrawText("Dropped files:", 100, 40, 20, Raylib.DARKGRAY)

            for i = 1:length(droppedFiles)
                if i % 2 == 1
                    Raylib.DrawRectangle(0, 85 + 40*(i-1), screenWidth, 40, Raylib.Fade(Raylib.LIGHTGRAY, 0.5))
                else
                    Raylib.DrawRectangle(0, 85 + 40*(i-1), screenWidth, 40, Raylib.Fade(Raylib.LIGHTGRAY, 0.3))
                end

                Raylib.DrawText(droppedFiles[i], 120, 100 + 40*(i-1), 10, Raylib.GRAY)

            end
            Raylib.DrawText("Dropped new files...", 100, 110 + 40length(droppedFiles), 20, Raylib.DARKGRAY)            
        end

        Raylib.EndDrawing()
    end

    Raylib.ClearDroppedFiles()
    Raylib.CloseWindow()
end
