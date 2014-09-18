
#
# SpriteState Abstraction
#

require! \std
require! \./units


# State masks

NONE          = 2^0
STANDING      = 2^1
WALKING       = 2^2
JUMPING       = 2^3
FALLING       = 2^4
INTERACTING   = 2^5
LEFT          = 2^6
RIGHT         = 2^7
UP            = 2^8
DOWN          = 2^9
HORIZONTAL    = 2^10
STRIDE_LEFT   = 2^11
STRIDE_RIGHT  = 2^12
STRIDE_MIDDLE = 2^13

export State = {
  NONE, STANDING, WALKING, JUMPING, FALLING,
  INTERACTING, LEFT, RIGHT, UP, DOWN, HORIZONTAL,
  STRIDE_LEFT, STRIDE_RIGHT, STRIDE_MIDDLE
}


# Collections for iteration

export motions  = [ STANDING, WALKING, JUMPING, FALLING, INTERACTING ]
export hfacings = [ LEFT, RIGHT ]
export vfacings = [ UP, DOWN, HORIZONTAL ]
export strides  = [ STRIDE_LEFT, STRIDE_RIGHT, STRIDE_MIDDLE ]


# SpriteState constructor

export SpriteState =
  make: (hfacing, vfacing, motion = NONE, stride = NONE) ->
    key: hfacing .|. vfacing .|. motion .|. stride
    UP:    vfacing is UP
    DOWN:  vfacing is DOWN
    LEFT:  hfacing is LEFT
    RIGHT: hfacing is RIGHT
    WALKING:  motion is WALKING
    JUMPING:  motion is JUMPING
    FALLING:  motion is FALLING
    STANDING: motion is STANDING
    HORIZONTAL : vfacing is HORIZONTAL
    INTERACTING: motion is INTERACTING
    STRIDE_LEFT  : stride is STRIDE_LEFT
    STRIDE_RIGHT : stride is STRIDE_RIGHT
    STRIDE_MIDDLE: stride is STRIDE_MIDDLE

  generate-with: (fn) ->
    std.mash [ (ss = SpriteState.make h, v, m, s; [ ss.key, fn ss ]) for m in motions
                                                                     for h in hfacings
                                                                     for v in vfacings
                                                                     for s in strides ]

