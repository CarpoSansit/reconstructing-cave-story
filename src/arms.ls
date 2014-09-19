
#
# Arms
#
# All the different guns
#


require! \std
require! \./units

{ kHalfTile, tile-to-px, tile-to-game, game-to-px } = units

{ Sprite }             = require \./sprite
{ SpriteState, State } = require \./spritestate

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

# Projectile sprite tiles
kProjectileSourceY         = 2
kHorizProjectileSourceX    = 8
kVerticalProjectileSourceX = 9

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


# Private Class: Projectile

class Projectile
  (@sprite, @state, @x, @y) ->
    @offset = 0

  update: (elapsed-time) ->

  draw: (graphics) ->
    @sprite.draw graphics, @x, @y


# Arms abstract class
#
# Not currently needed

# Polar Star

export class PolarStar

  (graphics) ->
    @projectile = null
    @sprites = @initialise-sprites graphics

    @hp-sprite = new Sprite graphics, \bullet,
      tile-to-px(kHorizProjectileSourceX), tile-to-px(kProjectileSourceY),
      tile-to-px(1), tile-to-px(1)

    @vp-sprite = new Sprite graphics, \bullet,
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

  start-fire: (state, player-x, player-y) ->
    bullet-x = (@gun-x state, player-x) - kHalfTile
    bullet-y = (@gun-y state, player-y) - kHalfTile

    switch true
    | state.HORIZONTAL =>
      bullet-y += kNozzleHorizY
      bullet-x += if state.LEFT then kNozzleHorizLeftX else kNozzleHorizRightX

    | state.UP =>
      bullet-y += kNozzleUpY
      bullet-x += if state.LEFT then kNozzleUpLeftX    else kNozzleUpRightX

    | state.DOWN =>
      bullet-y += kNozzleDownY
      bullet-x += if state.LEFT then kNozzleDownLeftX  else kNozzleDownRightX

    @projectile =
      new Projectile (if state.HORIZONTAL then @hp-sprite else @vp-sprite),
        state, bullet-x, bullet-y

  stop-fire: ->
    @projectile = null


  # Coordinates getters

  gun-x: (state, player-x) ->
    if state.LEFT then player-x - kHalfTile else player-x

  gun-y: (state, player-y) ->
    if state.UP   then player-y -= kHalfTile / 2
    if state.DOWN then player-y += kHalfTile / 2
    player-y + @gun-bob state

  gun-bob: (state) ->
    if state.WALKING and (state.STRIDE_LEFT or state.STRIDE_RIGHT) then -2 else 0


  # Update methods

  update: (elapsed-time) ->
    @projectile?.update elapsed-time

  draw: (graphics, player-x, player-y, state) ->
    gun-x = @gun-x state, player-x
    gun-y = @gun-y state, player-y

    @sprites[ state.key ].draw graphics, gun-x, gun-y

    @projectile?.draw graphics

