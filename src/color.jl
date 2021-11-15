using Colors
using Colors: N0f8

const RayColor = RGBA{Colors.N0f8}

raycolor(rgba...) = RayColor(map(Base.Fix1(reinterpret, N0f8)∘Cuchar, rgba)...)

"raylib defined Light Gray"
const LIGHTGRAY = raycolor( 200, 200, 200, 255 )
"raylib defined Gray"
const GRAY      = raycolor( 130, 130, 130, 255 )
"raylib defined Dark Gray"
const DARKGRAY  = raycolor( 80, 80, 80, 255 )
"raylib defined Yellow"
const YELLOW    = raycolor( 253, 249, 0, 255 )
"raylib defined Gold"
const GOLD      = raycolor( 255, 203, 0, 255 )
"raylib defined Orange"
const ORANGE    = raycolor( 255, 161, 0, 255 )
"raylib defined Pink"
const PINK      = raycolor( 255, 109, 194, 255 )
"raylib defined Red"
const RED       = raycolor( 230, 41, 55, 255 )
"raylib defined Maroon"
const MAROON    = raycolor( 190, 33, 55, 255 )
"raylib defined Green"
const GREEN     = raycolor( 0, 228, 48, 255 )
"raylib defined Lime"
const LIME      = raycolor( 0, 158, 47, 255 )
"raylib defined Dark Green"
const DARKGREEN = raycolor( 0, 117, 44, 255 )
"raylib defined Sky Blue"
const SKYBLUE   = raycolor( 102, 191, 255, 255 )
"raylib defined Blue"
const BLUE      = raycolor( 0, 121, 241, 255 )
"raylib defined Dark Blue"
const DARKBLUE  = raycolor( 0, 82, 172, 255 )
"raylib defined Purple"
const PURPLE    = raycolor( 200, 122, 255, 255 )
"raylib defined Violet"
const VIOLET    = raycolor( 135, 60, 190, 255 )
"raylib defined Dark Purple"
const DARKPURPLE = raycolor( 112, 31, 126, 255 )
"raylib defined Beige"
const BEIGE     = raycolor( 211, 176, 131, 255 )
"raylib defined Brown"
const BROWN     = raycolor( 127, 106, 79, 255 )
"raylib defined Dark Brown"
const DARKBROWN = raycolor( 76, 63, 47, 255 )

"raylib defined White"
const WHITE     = raycolor( 255, 255, 255, 255 )
"raylib defined Black"
const BLACK     = raycolor( 0, 0, 0, 255 )
"raylib defined Transparent"
const BLANK     = raycolor( 0, 0, 0, 0 )
"raylib defined Magenta"
const MAGENTA   = raycolor( 255, 0, 255, 255 )
"raylib defined Ray White"
const RAYWHITE  = raycolor( 245, 245, 245, 255 )
