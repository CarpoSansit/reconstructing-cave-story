
#
# SpriteState Abstraction
#

require! \std
require! \./units


# State masks

NONE        = 2^0
STANDING    = 2^1
WALKING     = 2^2
JUMPING     = 2^3
FALLING     = 2^4
INTERACTING = 2^5
LEFT        = 2^6
RIGHT       = 2^7
UP          = 2^8
DOWN        = 2^9
HORIZONTAL  = 2^10

export State = {
  NONE, STANDING, WALKING, JUMPING, FALLING,
  INTERACTING, LEFT, RIGHT, UP, DOWN, HORIZONTAL
}


# Collections for iteration

export motions  = [ STANDING, WALKING, JUMPING, FALLING, INTERACTING ]
export hfacings = [ LEFT, RIGHT ]
export vfacings = [ UP, DOWN, HORIZONTAL ]


# SpriteState constructor

export SpriteState =
  make: (hfacing, vfacing, motion = NONE) ->
    Object.create null, do
      key: value: hfacing .|. vfacing .|. motion
      UP:    get: -> vfacing is UP
      DOWN:  get: -> vfacing is DOWN
      LEFT:  get: -> hfacing is LEFT
      RIGHT: get: -> hfacing is RIGHT
      WALKING:  get: -> motion is WALKING
      JUMPING:  get: -> motion is JUMPING
      FALLING:  get: -> motion is FALLING
      STANDING: get: -> motion is STANDING
      HORIZONTAL : get: -> vfacing is HORIZONTAL
      INTERACTING: get: -> motion is INTERACTING

  generate-with: (fn) ->
    std.mash [ (ss = SpriteState.make h, v, m; [ ss.key, fn ss ]) for m in motions
                                                                  for h in hfacings
                                                                  for v in vfacings ]

