using Raylib
using Raylib: RayCamera3D, rayvector, RayVector3, RayColor, raycolor,
    RAYWHITE, LIGHTGRAY, DARKGRAY, MAROON,
    RED, BLUE, LIME, GOLD, SKYBLUE, BLACK

function main()
    screenWidth = 800
    screenHeight = 450

    Raylib.InitWindow(screenWidth, screenHeight,
                      "raylib [core] example - 3d camera first person")

    camera = Ref(RayCamera3D(
        rayvector(4, 2, 4),
        rayvector(0, 1.8, 0),
        rayvector(0, 1, 0),
        60,
        0,
    ))

    heights = Vector{Cfloat}(undef, 20)
    positions = Vector{RayVector3}(undef, 20)
    colors = Vector{RayColor}(undef, 20)

    for i = 1:20
        heights[i] = rand(1:12)
        positions[i] = rayvector(
            rand(-15:15),
            heights[i] / 2,
            rand(-15:15),
        )
        colors[i] = raycolor(
            rand(20:255),
            rand(10:55),
            30,
            255,
        )
    end

    Raylib.SetCameraMode(camera[], 3)
    Raylib.SetTargetFPS(60)

    while !Raylib.WindowShouldClose()
        Raylib.UpdateCamera(camera)

        Raylib.BeginDrawing()
        Raylib.ClearBackground(RAYWHITE)

        Raylib.BeginMode3D(camera[])

        Raylib.DrawPlane(
            rayvector(0,0,0),
            rayvector(32, 32),
            LIGHTGRAY)

        Raylib.DrawCube(
            rayvector(-16, 2.5, 0), 1f0, 5f0, 32f0,
            BLUE)
        Raylib.DrawCube(
            rayvector(16, 2.5, 0), 1f0, 5f0, 32f0,
            LIME)
        Raylib.DrawCube(
            rayvector(0, 2.5, 16), 32f0, 5f0, 1f0,
            GOLD)


        for i = 1:20
            Raylib.DrawCube(
                positions[i], 2f0, heights[i], 2f0,
                colors[i])
            Raylib.DrawCubeWires(positions[i], 2f0, heights[i], 2f0,
                                 MAROON)

        end

        Raylib.EndMode3D()

        Raylib.DrawRectangle(10, 10, 220, 70,
                             Raylib.Fade(SKYBLUE, 0.5) )
        Raylib.DrawRectangleLines(10, 10, 220, 70, BLUE)

        Raylib.DrawText("First person camera default controls:",
                        20, 20, 10, BLACK)
        Raylib.DrawText("- Move with keys: W, A, S, D",
                        40, 40, 10, DARKGRAY)
        Raylib.DrawText("- Mouse move to look around",
                        40, 60, 10, DARKGRAY)

        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()

end
