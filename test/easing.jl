#=
    # The four inputs t, b, c, d are defined as follows:

    * t = current time (in any unit measure, but same unit as duration)
    * b = starting value to interpolate
    * c = the total change in value of b that needs to occur
    * d = total time it should take to complete (duration)
=#

@testset "easing" begin
    currentTime = 0
    duration = 100
    startPositionX = 0
    finalPositionX = 30
    currentPositionX = startPositionX

    while (currentPositionX < finalPositionX)
        currentPositionX = Raylib.EaseSineIn(currentTime, startPositionX, finalPositionX - startPositionX, duration)
        currentTime += 1
        @show (currentTime, currentPositionX)
    end
end
