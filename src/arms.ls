
#
# Arms
#
# All the different guns
#


require! \std
require! \./units

{ kHalfTile, tile-to-px, tile-to-game, game-to-px } = units

{ Sprite } = require \./sprite
{ STANDING, WALKING, JUMPING, FALLING, INTERACTING,
LEFT, RIGHT, UP, DOWN, HORIZONTAL }:SpriteState = require \./spritestate

# Assets
kArmsSpritePath   = 'data/16x16/Arms.bmp'

# Spritestate tile offsets
kSpriteWidth      = 1.5
kSpriteHeight     = 1.0
kUpOffset         = 2
kDownOffset       = 4
kHorizontalOffset = 0
kRightOffset      = 1
kLeftOffset       = 0

# Weapon tile offsets
kPolarStarIndex = 2


# Arms abstract class
#
# Not currently needed



# Polar Star

export class PolarStar

  (graphics) ->

    std.log @sprites = @initialise-sprites graphics


  initialise-sprite: (graphics, hfacing, vfacing) ->

    tile-y = if hfacing is LEFT then kLeftOffset else kRightOffset

    switch vfacing
    | HORIZONTAL => tile-y += kHorizontalOffset
    | UP         => tile-y += kUpOffset
    | DOWN       => tile-y += kDownOffset
    | otherwise  => void

    new Sprite graphics, kArmsSpritePath, tile-to-px(kPolarStarIndex * kSpriteWidth),
      tile-to-px(tile-y), tile-to-px(kSpriteWidth), tile-to-px(kSpriteHeight)

  initialise-sprites: (graphics, sprite-map = {}) ->
    for hfacing in [ LEFT, RIGHT ]
      for vfacing in [ UP, DOWN, HORIZONTAL ]
        sprite-map[ SpriteState.key hfacing, vfacing ] =
          @initialise-sprite graphics, hfacing, vfacing
    return sprite-map

  update: (elapsed-time) ->

  draw: (graphics, x, y, hfacing, vfacing) ->

    x-offset = if hfacing is LEFT then -kHalfTile else 0
    y-offset = if vfacing is UP   then -kHalfTile / 2 else 0
    y-offset = if vfacing is DOWN then  kHalfTile / 2 else 0

    @sprites[ SpriteState.key hfacing, vfacing ].draw graphics,
      x + x-offset, y + y-offset



