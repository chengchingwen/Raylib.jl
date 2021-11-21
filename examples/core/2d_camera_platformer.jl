using Raylib
using Raylib: rayvector, IsKeyDown
using StaticArrays

const G = 400
const PLAYER_JUMP_SPD = 350
const PLAYER_HOR_SPD = 200

mutable struct Player
    pos_x::Float64
    pos_y::Float64
    speed::Float64
    canJump::Bool
end
Player(pos, s, j) = Player(pos..., s, j)

position(p::Player) = rayvector(p.pos_x, p.pos_y)

struct EnvItem
    rect::Raylib.RayRectangle
    blocking::Bool
    color::Raylib.RayColor
end

function isoverlap(item, player, movement)
    rect = item.rect
    pos = position(player)
    return rect.x <= pos.x <= rect.x + rect.width &&
        rect.y - movement < pos.y <= rect.y
end

function UpdatePlayer!(player::Player, envItems::Vector{EnvItem}, delta::Float32)
    hor_movement = PLAYER_HOR_SPD*delta
    ver_movement = player.speed * delta

    IsKeyDown(Raylib.KEY_LEFT)  && (player.pos_x -= hor_movement)
    IsKeyDown(Raylib.KEY_RIGHT) && (player.pos_x += hor_movement)

    if IsKeyDown(Raylib.KEY_SPACE) && player.canJump
        player.speed = -PLAYER_JUMP_SPD
        player.canJump = false
    end

    hitObstacle = false
    for ei in envItems
        if ei.blocking && isoverlap(ei, player, ver_movement)
            player.speed = 0
            player.pos_y = ei.rect.y
            hitObstacle = true
        end
    end

    if !hitObstacle
        player.pos_y += ver_movement
        player.speed += G*delta
        player.canJump = false
    else
        player.canJump = true
    end

    return player
end

function UpdateCameraCenter(
    camera::Raylib.RayCamera2D,
    player::Player, _, _,
    width::Int64,
    height::Int64,
)
    camera.offset = rayvector(width/2, height/2)
    camera.target = position(player)
    return camera
end

function UpdateCameraCenterInsideMap(
    camera::Raylib.RayCamera2D,
    player::Player,
    envItems::Vector{EnvItem},
    _,
    width::Int64,
    height::Int64,
)
    camera = UpdateCameraCenter(camera, player, envItems, nothing, width, height)

    minX = minY = 1000; maxX = maxY = -1000

    minX = minimum(item->item.rect.x, envItems; init=1000)
    minY = minimum(item->item.rect.y, envItems; init=1000)
    maxX = maximum(item->item.rect.x + item.rect.width, envItems; init=-1000)
    maxY = maximum(item->item.rect.y + item.rect.height, envItems; init=-1000)

    maxbound = Raylib.GetWorldToScreen2D(rayvector(maxX, maxY), camera)
    minbound = Raylib.GetWorldToScreen2D(rayvector(minX, minY), camera)

    (maxbound.x < width)  && (camera.offset_x = width  - (maxbound.x - width/2))
    (maxbound.y < height) && (camera.offset_y = height - (maxbound.y - height/2))
    (minbound.x > 0) && (camera.offset_x = width/2  - minbound.x)
    (minbound.y > 0) && (camera.offset_y = height/2 - minbound.y)
    return camera
end

function UpdateCameraCenterSmoothFollow(
    camera::Raylib.RayCamera2D,
    player::Player,
    _,
    delta::Float32,
    width::Int64,
    height::Int64
)
    minSpeed = 30
    minEffectLength = 10
    fractionSpeed = 0.8

    camera.offset = rayvector(width/2, height/2)

    diff = position(player) - camera.target
    length = sqrt(sum(diff.^2))

    if length > minEffectLength
        speed = max(fractionSpeed*length, minSpeed);
        camera.target += speed*delta/length .* diff
    end

    return camera
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
    _,
    delta::Float32,
    width::Int64,
    height::Int64
)
    camera.offset = rayvector(width/2, height/2)
    camera.target = rayvector(player.pos_x, camera.target[2])

    if uceool_argv.eveningOut
        if uceool_argv.evenOutTarget > camera.target[2]
            camera.target += rayvector(0, uceool_argv.evenOutSpeed*delta)

            if camera.target[2] > uceool_argv.evenOutTarget
                camera.target = rayvector(camera.target[1], uceool_argv.evenOutTarget)
                uceool_argv.eveningOut = 0
            end
        else
            camera.target -= rayvector(0, uceool_argv.evenOutSpeed*delta)

            if camera.target[2] < uceool_argv.evenOutTarget
                camera.target = rayvector(camera.target[1], uceool_argv.evenOutTarget)
                uceool_argv.eveningOut = 0
            end
        end
    else
        if player.canJump && player.speed == 0 && player.pos_y != camera.target[2]
            uceool_argv.eveningOut = 1
            uceool_argv.evenOutTarget = player.pos_y
        end
    end

    return camera
end

function UpdateCameraPlayerBoundsPush(
    camera::Raylib.RayCamera2D,
    player::Player,
    _, _,
    width::Int64,
    height::Int64
)
    bbox = rayvector(0.2, 0.2)
    worldbox = 0.5rayvector(width, height)

    bboxWorldMin = Raylib.GetScreenToWorld2D(worldbox .* (1 .- bbox), camera)
    bboxWorldMax = Raylib.GetScreenToWorld2D(worldbox .* (1 .+ bbox), camera)
    camera.offset = worldbox .* (1 .- bbox)

    (player.pos_x < bboxWorldMin.x) &&  (camera.target_x = player.pos_x)
    (player.pos_y < bboxWorldMin.y) &&  (camera.target_y = player.pos_y)
    (player.pos_x > bboxWorldMax.x) &&  (camera.target_x = bboxWorldMin.x + player.pos_x - bboxWorldMax.x)
    (player.pos_y > bboxWorldMax.y) &&  (camera.target_y = bboxWorldMin.y + player.pos_y - bboxWorldMax.y)

    return camera
end

const screenWidth = 800
const screenHeight = 450

function main()
    Raylib.InitWindow(
        screenWidth, screenHeight,
        "raylib [core] example - 2d camera"
    )

    player = Player(400, 280, 0, false)
    envItems = [
        EnvItem(Raylib.RayRectangle(0, 0, 1000, 400), false, Raylib.LIGHTGRAY),
        EnvItem(Raylib.RayRectangle(0, 400, 1000, 200), true, Raylib.GRAY),
        EnvItem(Raylib.RayRectangle(300, 200, 400, 10), true, Raylib.GRAY),
        EnvItem(Raylib.RayRectangle(250, 300, 100, 10), true, Raylib.GRAY),
        EnvItem(Raylib.RayRectangle(650, 300, 100, 10), true, Raylib.GRAY),
    ]

    camera = Raylib.RayCamera2D(
        rayvector(screenWidth/2, screenHeight/2),
        position(player),
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

        UpdatePlayer!(player, envItems, deltaTime)

        zoom = camera.zoom + 0.05Raylib.GetMouseWheelMove()
        camera.zoom = max(min(3, zoom), 0.25)

        if Raylib.IsKeyPressed(Raylib.KEY_R)
            camera.zoom = 1
            player.pos_x, player.pos_y = (400, 280)
        end

        if Raylib.IsKeyPressed(Raylib.KEY_C)
            cameraOption = mod1(cameraOption+1, cameraUpdatersLength)
        end

        # Call update camera function by its pointer
        camera = cameraUpdaters[cameraOption](
            camera,
            player,
            envItems,
            deltaTime,
            screenWidth,
            screenHeight
        )

        # Draw
        Raylib.BeginDrawing()

        Raylib.ClearBackground(Raylib.LIGHTGRAY)

        Raylib.BeginMode2D(camera)

        for ei in envItems
            Raylib.DrawRectangleRec(ei.rect, ei.color)
        end

        playerRect = Raylib.RayRectangle(position(player) .- (20, 40), 40, 40)
        Raylib.DrawRectangleRec(playerRect, Raylib.RED)

        Raylib.EndMode2D()

        Raylib.DrawText("Controls:", 20, 20, 10, Raylib.BLACK);
        Raylib.DrawText("- Right/Left to move", 40, 40, 10, Raylib.DARKGRAY);
        Raylib.DrawText("- Space to jump", 40, 60, 10, Raylib.DARKGRAY);
        Raylib.DrawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, Raylib.DARKGRAY);
        Raylib.DrawText("- C to change camera mode", 40, 100, 10, Raylib.DARKGRAY);
        Raylib.DrawText("Current camera mode:", 20, 120, 10, Raylib.BLACK);
        Raylib.DrawText(cameraDescriptions[cameraOption], 40, 140, 10, Raylib.DARKGRAY);

        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()
end
