# const easings_api = Raylib.Binding.parse(
#     joinpath(dirname(@__DIR__), "api_reference/easings_api.xml")
# )

# for func in easings_api[:raylibAPI][:Functions][:Function]
#     name = Symbol(func[:attr].name)
#     if isdefined(@__MODULE__, name)
#         @info "duplicat $name from easings. skip"
#         continue
#     end

#     expr = Raylib.Binding.gen_func(func)
#     if isnothing(expr)
#         @info "failed to generate function: $func"
#     else
#         try
#             @eval $expr
#         catch
#             @show "easings", expr
#         end
#     end
# end

#=
    # The four inputs t, b, c, d are defined as follows:

    * t = current time (in any unit measure, but same unit as duration)
    * b = starting value to interpolate
    * c = the total change in value of b that needs to occur
    * d = total time it should take to complete (duration)
=#

# Linear Easing functions
EaseLinearNone(t::Real, b::Real, c::Real, d::Real) = c * t/d + b
EaseLinearIn(t::Real, b::Real, c::Real, d::Real) = EaseLinearNone(t, b, c, d)
EaseLinearOut(t::Real, b::Real, c::Real, d::Real) = EaseLinearNone(t, b, c, d)
EaseLinearInOut(t::Real, b::Real, c::Real, d::Real) = EaseLinearNone(t, b, c, d)

# Sine Easing functions
EaseSineIn(t::Real, b::Real, c::Real, d::Real) = -c * cos(t/d * (π/2)) + c + b
EaseSineOut(t::Real, b::Real, c::Real, d::Real) = c * sinf(t/d * (π/2)) + b
EaseSineInOut(t::Real, b::Real, c::Real, d::Real) = -c/2 * (cos(π * t/d) - 1) + b

# Circular Easing functions
function EaseCircIn(t::Real, b::Real, c::Real, d::Real)
    t /= d

    return -c * (sqrt(1 - t^2) - 1) + b
end
function EaseCircOut(t::Real, b::Real, c::Real, d::Real)
    t = t/d - 1

    return c * sqrt(1 - t^2) + b
end
function EaseCircInOut(t::Real, b::Real, c::Real, d::Real)
    if (t /= d/2) < 1
        return -c/2 * (sqrt(1 - t^2) - 1) + b
    end

    t -= 2

    return c/2 * (sqrt(1 - t^2) + 1) + b
end

# Cubic Easing functions
function EaseCubicIn(t::Real, b::Real, c::Real, d::Real)
    t /= d

    return c * t^3 + b
end
function EaseCubicOut(t::Real, b::Real, c::Real, d::Real)
    t = t/d - 1

    return c * (t^3 + 1) + b
end
function EaseCubicInOut(t::Real, b::Real, c::Real, d::Real)
    if (t /= d/2) < 1
        return c/2 * t^3 + b
    end

    t -= 2

    return c/2 * (t^3 + 2) + b
end

# Quadratic Easing functions
function EaseQuadIn(t::Real, b::Real, c::Real, d::Real)
    t /= d

    return c * t^2 + b
end
function EaseQuadOut(t::Real, b::Real, c::Real, d::Real)
    t /= d

    return -c * t * (t - 2) + b
end
function EaseQuadInOut(t::Real, b::Real, c::Real, d::Real)
    if (t /= d/2) < 1
        return c/2 * t^2 + b
    end

    return -c/2 * ((t - 1) * (t - 3) - 1) + b
end

# Exponential Easing functions
function EaseExpoIn(t::Real, b::Real, c::Real, d::Real)
    return iszero(t) ? b : c * 2^(10(t/d - 1)) + b
end
function EaseExpoOut(t::Real, b::Real, c::Real, d::Real)
    return iszero(t-d) ? b+c : c * (-(2.0^(-10 * t/d)) + 1) + b
end
function EaseExpoInOut(t::Real, b::Real, c::Real, d::Real)
    if iszero(t)
        return b
    elseif iszero(t-d)
        return b + c
    elseif (t /= d/2) < 1
        return c/2 * 2^(10(t - 1)) + b
    else
        return c/2 * (-(2^(-10(t - 1))) + 2) + b
    end
end

# Back Easing functions
function EaseBackIn(t::Real, b::Real, c::Real, d::Real)
    s = 1.70158
    postFix = t/=d

    return c * postFix * t * ((s + 1) * t - s) + b
end
function EaseBackOut(t::Real, b::Real, c::Real, d::Real)
    s = 1.70158
    t = t/d - 1

    return c * (t^2 * ((s + 1) * t + s) + 1) + b
end
function EaseBackInOut(t::Real, b::Real, c::Real, d::Real)
    s = 1.70158

    if (t /= d/2) < 1
        s *= 1.525
        return c/2 * t^2 * ((s + 1) * t - s) + b
    end

    postFix = t -= 2
    s *= 1.525

    return c/2 * (postFix * t * ((s + 1) * t + s) + 2) + b
end

# Bounce Easing functions
function EaseBounceIn(t::Real, b::Real, c::Real, d::Real)
    return c - EaseBounceOut(d-t, 0, c, d) + b
end
function EaseBounceOut(t::Real, b::Real, c::Real, d::Real)
    if (t /= d) < 1/2.75
        return c * (7.5625 * t^2) + b
    elseif t < 2/2.75
        postFix = t -= 1.5/2.75
        return c * (7.5625postFix * t + 0.75) + b
    elseif t < 2.5/2.75
        postFix = t -= 2.25/2.75
        return c * (7.5625postFix * t + 0.9375) + b
    else
        postFix = t -= 2.625/2.75
        return c * (7.5625postFix * t + 0.984375) + b
    end
end
function EaseBounceInOut(t::Real, b::Real, c::Real, d::Real)
    if (t < d/2)
        return EaseBounceIn(2t, 0, c, d)/2 + b
    end

    return EaseBounceOut(2t-d, 0, c, d)/2 + c/2 + b
end

# Elastic Easing functions
function EaseElasticIn(t::Real, b::Real, c::Real, d::Real)
    iszero(t) && (return b)
    isone(t/=d) && (return b + c)

    p = 0.3d
    a = c
    s = p/4
    postFix = a * 2^(10(t -= 1))

    return -(postFix * sin((t * d - s) * 2π/p )) + b
end
function EaseElasticOut(t::Real, b::Real, c::Real, d::Real)
    iszero(t) && (return b)
    isone(t /= d) && (return b + c)

    p = 0.3d
    a = c
    s = p/4

    return a * 2^(-10t) * sin((t * d - s) * 2π/p) + c + b
end
function EaseElasticInOut(t::Real, b::Real, c::Real, d::Real)
    iszero(t) && (return b)
    ((t /= d/2) == 2) && (return b + c)

    p = d * 0.3 * 1.5
    a = c
    s = p/4

    if t < 1
        postFix = a * 2^(10(t -= 1))
        return -0.5(postFix * sin((t*d - s) * 2π/p)) + b
    end

    postFix = a * 2^(-10(t -= 1))
    return postFix * sin((t*d - s) * 2π/p) / 2 + c + b
end
