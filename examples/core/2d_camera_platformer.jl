using Raylib
using StaticArrays

const G = 400
const PLAYER_JUMP_SPD = 350
const PLAYER_HOR_SPD = 200

mutable struct Player
    position::SVector{2, Float32}
    speed::Float32
    canJump::Bool
end

struct EnvItem
    rect::Raylib.RayRectangle
    blocking::Bool
    color::Raylib.RayColor
end

function UpdatePlayer!(player::Player, envItems::Vector{EnvItem}, envItemsLength::Int64, delta::Float32)
    if Raylib.IsKeyDown(Int(Raylib.KEY_LEFT))
        player.position = Raylib.rayvector(player.position[1]-PLAYER_HOR_SPD*delta, player.position[2])
    end
    if Raylib.IsKeyDown(Int(Raylib.KEY_RIGHT))
        player.position = Raylib.rayvector(player.position[1]+PLAYER_HOR_SPD*delta, player.position[2])
    end
    if Raylib.IsKeyDown(Int(Raylib.KEY_SPACE)) && player.canJump
        player.speed = -PLAYER_JUMP_SPD
        player.canJump = false
    end

    hitObstacle = false
    for i in 1:envItemsLength

        ei = envItems[i]
        p = player.position
        if (
            ei.blocking &&
            ei.rect.x <= p[1] &&
            ei.rect.x + ei.rect.width >= p[1] &&
            ei.rect.y >= p[2] &&
            ei.rect.y < p[2] + player.speed*delta
        )
            hitObstacle = true
            player.speed = 0
            player.position = Raylib.rayvector(p[1], ei.rect.y)
        end
    end

    if !hitObstacle
        player.position = Raylib.rayvector(player.position[1], player.position[2]+player.speed*delta)
        player.speed += G*delta
        player.canJump = false
    else
        player.canJump = true
    end

    return player
end


function UpdateCameraCenter(
    camera::Raylib.RayCamera2D,
    player::Player,
    envItems::Vector{EnvItem},  #
    envItemsLength::Int64,  #
    delta::Float32, #
    width::Int64,
    height::Int64
)
    offset = Raylib.rayvector(width/2, height/2)
    target = player.position

    return Raylib.RayCamera2D(offset, target, camera.rotation, camera.zoom)
end

function UpdateCameraCenterInsideMap(
    camera::Raylib.RayCamera2D,
    player::Player,
    envItems::Vector{EnvItem},
    envItemsLength::Int64,
    delta::Float32, #
    width::Int64,
    height::Int64
)
    camera = UpdateCameraCenter(camera, player, envItems, envItemsLength, delta, width, height)

    minX = minY = 1000; maxX = maxY = -1000
    for i in 1:envItemsLength
        ei = envItems[i]
        minX = min(ei.rect.x, minX)
        maxX = max(ei.rect.x + ei.rect.width, maxX)
        minY = min(ei.rect.y, minY)
        maxY = max(ei.rect.y + ei.rect.height, maxY)
    end

    max_ = Raylib.GetWorldToScreen2D(Raylib.rayvector(maxX, maxY), camera)
    min_ = Raylib.GetWorldToScreen2D(Raylib.rayvector(minX, minY), camera)

    offset = camera.offset
    (max_[1] < width) && (offset = Raylib.rayvector(width - (max_[1] - width/2), camera.offset[2]))
    (max_[2] < height) && (offset = Raylib.rayvector(camera.offset[1], height - (max_[2] - height/2)))
    (min_[1] > 0) && (offset = Raylib.rayvector(width/2 - min_[1], camera.offset[2]))
    (min_[2] > 0) && (offset = Raylib.rayvector(camera.offset[1], height/2 - min_[2]))

    return Raylib.RayCamera2D(offset, camera.target, camera.rotation, camera.zoom)
end

function UpdateCameraCenterSmoothFollow(
    camera::Raylib.RayCamera2D,
    player::Player,
    envItems::Vector{EnvItem},  #
    envItemsLength::Int64,  #
    delta::Float32,
    width::Int64,
    height::Int64
)
    minSpeed = 30
    minEffectLength = 10
    fractionSpeed = 0.8

    offset = Raylib.rayvector(width/2, height/2)
    diff = player.position - camera.target
    length = sqrt(sum(diff.^2))

    target = camera.target
    if length > minEffectLength
        speed = max(fractionSpeed*length, minSpeed);
        target = target + speed*delta/length .* diff
    end

    return Raylib.RayCamera2D(offset, target, camera.rotation, camera.zoom)
end

mutable struct UpdateCameraEvenOutOnLandingArgv
    evenOutSpeed::Float32
    eveningOut::Bool
    evenOutTarget::Float32
end

const uceool_argv = UpdateCameraEvenOutOnLandingArgv(700, false, 0)

function UpdateCameraEvenOutOnLanding(
    camera::Raylib.RayCamera2D,
    player::Player,
    envItems::Vector{EnvItem},  #
    envItemsLength::Int64,  #
    delta::Float32,
    width::Int64,
    height::Int64
)
    camera = Raylib.RayCamera2D(
        Raylib.rayvector(width/2, height/2),
        Raylib.rayvector(player.position[1], camera.target[2]),
        camera.rotation,
        camera.zoom
    )

    if uceool_argv.eveningOut
        if uceool_argv.evenOutTarget > camera.target[2]
            camera = Raylib.RayCamera2D(
                camera.offset,
                Raylib.rayvector(camera.target[1], camera.target[2] + uceool_argv.evenOutSpeed*delta),
                camera.rotation,
                camera.zoom
            )

            if camera.target[2] > uceool_argv.evenOutTarget
                camera = Raylib.RayCamera2D(
                    camera.offset,
                    Raylib.rayvector(camera.target[1], uceool_argv.evenOutTarget),
                    camera.rotation,
                    camera.zoom
                )
                uceool_argv.eveningOut = 0
            end
        else
            camera = Raylib.RayCamera2D(
                camera.offset,
                Raylib.rayvector(camera.target[1], camera.target[2] - uceool_argv.evenOutSpeed*delta),
                camera.rotation,
                camera.zoom
            )

            if camera.target[2] < uceool_argv.evenOutTarget
                camera = Raylib.RayCamera2D(
                    camera.offset,
                    Raylib.rayvector(camera.target[1], uceool_argv.evenOutTarget),
                    camera.rotation,
                    camera.zoom
                )
                uceool_argv.eveningOut = 0
            end
        end
    else
        if player.canJump && player.speed == 0 && player.position[2] != camera.target[2]
            uceool_argv.eveningOut = 1
            uceool_argv.evenOutTarget = player.position[2]
        end
    end

    return camera
end

function UpdateCameraPlayerBoundsPush(
    camera::Raylib.RayCamera2D,
    player::Player,
    envItems::Vector{EnvItem},  #
    envItemsLength::Int64,  #
    delta::Float32, #
    width::Int64,
    height::Int64
)
    bbox = Raylib.rayvector(0.2, 0.2)

    bboxWorldMin = Raylib.GetScreenToWorld2D(Raylib.rayvector((1 - bbox[1])*0.5*width, (1 - bbox[2])*0.5*height), camera)
    bboxWorldMax = Raylib.GetScreenToWorld2D(Raylib.rayvector((1 + bbox[1])*0.5*width, (1 + bbox[2])*0.5*height), camera)
    camera = Raylib.RayCamera2D(
        Raylib.rayvector((1 - bbox[1])*0.5 * width, (1 - bbox[2])*0.5*height),
        camera.target,
        camera.rotation,
        camera.zoom
    )

    target = camera.target
    (player.position[1] < bboxWorldMin[1]) &&  (target = Raylib.rayvector(player.position[1], camera.target[2]))
    (player.position[2] < bboxWorldMin[2]) &&  (target = Raylib.rayvector(camera.target[1], player.position[2]))
    (player.position[1] > bboxWorldMax[1]) &&  (target = Raylib.rayvector(bboxWorldMin[1] + player.position[1] - bboxWorldMax[1], camera.target[2]))
    (player.position[2] > bboxWorldMax[2]) &&  (target = Raylib.rayvector(camera.target[1], bboxWorldMin[2] + player.position[2] - bboxWorldMax[2]))

    return Raylib.RayCamera2D(camera.offset, target, camera.rotation, camera.zoom)
end

const screenWidth = 800
const screenHeight = 450

function main()
    Raylib.InitWindow(
        screenWidth, screenHeight,
        "raylib [core] example - 2d camera"
    )

    player = Player(Raylib.rayvector(400, 280), 0, false)
    envItems = [
        EnvItem(Raylib.RayRectangle(0, 0, 1000, 400), false, Raylib.LIGHTGRAY),
        EnvItem(Raylib.RayRectangle(0, 400, 1000, 200), true, Raylib.GRAY),
        EnvItem(Raylib.RayRectangle(300, 200, 400, 10), true, Raylib.GRAY),
        EnvItem(Raylib.RayRectangle(250, 300, 100, 10), true, Raylib.GRAY),
        EnvItem(Raylib.RayRectangle(650, 300, 100, 10), true, Raylib.GRAY),
    ]
    envItemsLength = length(envItems)

    camera = Raylib.RayCamera2D(
        Raylib.rayvector(screenWidth/2, screenHeight/2),
        player.position,
        0,
        1
    )
    cameraUpdaters = [
        UpdateCameraCenter,
        UpdateCameraCenterInsideMap,
        UpdateCameraCenterSmoothFollow,
        UpdateCameraEvenOutOnLanding,
        UpdateCameraPlayerBoundsPush
    ]
    cameraOption = 1
    cameraUpdatersLength = length(cameraUpdaters)
    cameraDescriptions = [
        "Follow player center",
        "Follow player center, but clamp to map edges",
        "Follow player center; smoothed",
        "Follow player center horizontally; updateplayer center vertically after landing",
        "Player push camera on getting too close to screen edge"
    ]

    Raylib.SetTargetFPS(60)
    while !Raylib.WindowShouldClose()
        # Update
        deltaTime = Raylib.GetFrameTime();

        UpdatePlayer!(player, envItems, envItemsLength, deltaTime)

        camera = Raylib.RayCamera2D(
            camera.offset,
            camera.target,
            camera.rotation,
            camera.zoom + Raylib.GetMouseWheelMove()*0.05
        )

        if camera.zoom > 3
            camera = Raylib.RayCamera2D(
                camera.offset,
                camera.target,
                camera.rotation,
                3
            )
        elseif camera.zoom < 0.25
            camera = Raylib.RayCamera2D(
                camera.offset,
                camera.target,
                camera.rotation,
                0.25
            )
        end

        if Raylib.IsKeyPressed(Int(Raylib.KEY_R))
            camera = Raylib.RayCamera2D(
                camera.offset,
                camera.target,
                camera.rotation,
                1
            )
            player.position = Raylib.rayvector(400, 280)
        end

        if Raylib.IsKeyPressed(Int(Raylib.KEY_C))
            cameraOption = cameraOption%cameraUpdatersLength + 1
        end

        # Call update camera function by its pointer
        camera = cameraUpdaters[cameraOption](
            camera,
            player,
            envItems,
            envItemsLength,
            deltaTime,
            screenWidth,
            screenHeight
        )

        # Draw
        Raylib.BeginDrawing()

        Raylib.ClearBackground(Raylib.LIGHTGRAY)

        Raylib.BeginMode2D(camera)

        for i in 1:envItemsLength
            Raylib.DrawRectangleRec(envItems[i].rect, envItems[i].color)
        end

        playerRect = Raylib.RayRectangle(player.position[1] - 20, player.position[2] - 40, 40, 40)
        Raylib.DrawRectangleRec(playerRect, Raylib.RED)

        Raylib.EndMode2D()

        Raylib.DrawText("Controls:", 20, 20, 10, Raylib.BLACK);
        Raylib.DrawText("- Right/Left to move", 40, 40, 10, Raylib.DARKGRAY);
        Raylib.DrawText("- Space to jump", 40, 60, 10, Raylib.DARKGRAY);
        Raylib.DrawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, Raylib.DARKGRAY);
        Raylib.DrawText("- C to change camera mode", 40, 100, 10, Raylib.DARKGRAY);
        Raylib.DrawText("Current camera mode:", 20, 120, 10, Raylib.BLACK);
        # DrawText(cameraDescriptions[cameraOption], 40, 140, 10, DARKGRAY);

        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()
end
