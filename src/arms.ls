
#
# Arms
#
# All the different guns
#


require! \std
require! \./units

{ kHalfTile, tile-to-px, tile-to-game, game-to-px } = units

{ Sprite }      = require \./sprite
{ SpriteState } = require \./spritestate

{ LEFT, RIGHT, UP, DOWN, HORIZONTAL } = require \./spritestate


# Assets
kArmsSpritePath   = \Arms

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

# Projectile nozzle offsets (game units)
kNozzleHorizY      = 23
kNozzleHorizLeftX  = 10
kNozzleHorizRightX = 38

kNozzleUpY      = 4
kNozzleUpLeftX  = 27
kNozzleUpRightX = 21

kNozzleDownY      = 28
kNozzleDownLeftX  = 29
kNozzleDownRightX = 19

# Projectile sprite tiles
kProjectileSourceY = 2
kHorizProjectileSourceX = 8
kVerticalProjectileSourceX = 9


# Arms abstract class
#
# Not currently needed


# Polar Star

export class PolarStar

  (graphics) ->
    @sprites = @initialise-sprites graphics

    @horizontal-projectile = new Sprite graphics, \bullet,
      tile-to-px(kHorizProjectileSourceX), tile-to-px(kProjectileSourceY),
      tile-to-px(1), tile-to-px(1)

    @vertical-projectile = new Sprite graphics, \bullet,
      tile-to-px(kVerticalProjectileSourceX), tile-to-px(kProjectileSourceY),
      tile-to-px(1), tile-to-px(1)

  initialise-sprites: (graphics) ->
    SpriteState.generate-with (state) ->
      tile-y = if state.LEFT then kLeftOffset else kRightOffset

      switch true
      | state.HORIZONTAL => tile-y += kHorizontalOffset
      | state.UP         => tile-y += kUpOffset
      | state.DOWN       => tile-y += kDownOffset

      new Sprite graphics, kArmsSpritePath,
        tile-to-px(kPolarStarIndex * kSpriteWidth), tile-to-px(tile-y),
        tile-to-px(kSpriteWidth), tile-to-px(kSpriteHeight)

  update: (elapsed-time) ->

  draw: (graphics, x, y, state, walk-keyframe) ->
    x-offset = if state.LEFT then -kHalfTile else 0
    y-offset = if state.UP   then -kHalfTile / 2 else 0
    y-offset = if state.DOWN then  kHalfTile / 2 else 0

    y-offset +=
      if state.WALKING and (state.STRIDE_LEFT or state.STRIDE_RIGHT)
        then -2 else 0

    @sprites[ state.key ].draw graphics, x + x-offset, y + y-offset

    bullet-y = y - kHalfTile + y-offset
    bullet-x = x - kHalfTile + x-offset

    switch true
    | state.HORIZONTAL =>
      bullet-y += kNozzleHorizY
      if state.LEFT =>
        bullet-x += kNozzleHorizLeftX
      else
        bullet-x += kNozzleHorizRightX

    | state.UP =>
      bullet-y += kNozzleUpY
      if state.LEFT =>
        bullet-x += kNozzleUpLeftX
      else
        bullet-x += kNozzleUpRightX

    | state.DOWN =>
      bullet-y += kNozzleDownY
      if state.LEFT =>
        bullet-x += kNozzleDownLeftX
      else
        bullet-x += kNozzleDownRightX

    if state.HORIZONTAL
      @horizontal-projectile.draw graphics, bullet-x, bullet-y
    else
      @vertical-projectile.draw   graphics, bullet-x, bullet-y

