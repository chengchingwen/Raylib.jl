using Raylib
using Raylib: RayCamera3D, rayvector,
    RAYWHITE, MAROON, RED, DARKGRAY

function main()
    screenWidth = 800
    screenHeight = 450
    
    Raylib.InitWindow(screenWidth, screenHeight,
                      "raylib [core] example - 3d camera mode")

    camera = RayCamera3D(
        rayvector(0, 10, 10),
        rayvector(0, 0, 0),
        rayvector(0, 1, 0),
        45,
        0,
    )

    cubePosition = rayvector(0, 0, 0)

    Raylib.SetTargetFPS(60)

    while iszero(Raylib.WindowShouldClose())
        Raylib.BeginDrawing()
        Raylib.ClearBackground(RAYWHITE)

        Raylib.BeginMode3D(camera)
        Raylib.DrawCube(cubePosition, 2f0, 2f0, 2f0, RED)
        
        Raylib.DrawCubeWires(cubePosition, 2f0, 2f0, 2f0, MAROON)

        Raylib.DrawGrid(10, 1f0)

        Raylib.EndMode3D()
        Raylib.DrawText("Welcome to the third dimension!",
                        10, 40, 20, DARKGRAY)
        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()

end
