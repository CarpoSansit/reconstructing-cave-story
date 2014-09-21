
#
# Arms
#
# All the different guns
#


require! \std
require! \./units

{ kHalfTile, tile-to-px, tile-to-game, game-to-px } = units

{ WALL_TILE }          = require \./map
{ Sprite }             = require \./sprite
{ Rectangle: Rect }    = require \./rectangle
{ SpriteState, State } = require \./spritestate
{ Projectile }         = require \./projectile


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

# Projectile properties
kL1Lifespan        = 7 * kHalfTile
kL1Speed           = 0.6
kL1CollisionWidth  = 32
kL1CollisionHeight = 4


# Private Class: Projectile

class PolarStarProjectile extends Projectile
  (@sprite, state, x, y) ->
    super 1

    @offset   = 0
    @lifespan = kL1Lifespan
    @alive    = yes

    std.log 'SFX: Pew!'

    @width  = if state.HORIZONTAL then kL1CollisionWidth  else kL1CollisionHeight
    @height = if state.HORIZONTAL then kL1CollisionHeight else kL1CollisionWidth

    Object.define-properties this, do
      x: get:
        if  not state.HORIZONTAL then -> x
        else if state.LEFT       then -> x - @offset
        else if state.RIGHT      then -> x + @offset
      y: get:
        if      state.HORIZONTAL then -> y
        else if state.UP         then -> y - @offset
        else if state.DOWN       then -> y + @offset

  collision-rectangle: ->
    # BUG:
    # Why is this adjustment necessary? and why do I need kHalftile in one
    # direction but not the other? If you enable graphics.visualise-rect you
    # can see that the adjustment makes the collision box line up perfectly,
    # but I don't know whats wrong that makes it necessary

    adjust = 2

    new Rect @x + kHalfTile - @width / 2,
      @y + @width / 2 - adjust,
      @width, @height

  update: (elapsed-time, map) ->
    @offset += kL1Speed * elapsed-time
    for tile in map.get-colliding-tiles @collision-rectangle!
      if tile.type is WALL_TILE
        return false
    return @alive and @offset < @lifespan

  draw: (graphics) ->
    @sprite.draw graphics, @x, @y
    #graphics.visualiseRect @collision-rectangle!

  collide-with-enemy: ->
    @alive = false

# Arms abstract class
#
# Not currently needed

# Polar Star

export class PolarStar

  (graphics) ->
    @projectile-a = null
    @projectile-b = null
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

    # If both projectiles are in use, bail
    return if @projectile-a and @projectile-b

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

    # Use next available projectile
    if not @projectile-a
      @projectile-a =
        new PolarStarProjectile (if state.HORIZONTAL then @hp-sprite else @vp-sprite),
          state, bullet-x, bullet-y

    else if not @projectile-b
      @projectile-b =
        new PolarStarProjectile (if state.HORIZONTAL then @hp-sprite else @vp-sprite),
          state, bullet-x, bullet-y

  stop-fire: ->


  # Coordinates getters

  gun-x: (state, player-x) ->
    if state.LEFT then player-x - kHalfTile else player-x

  gun-y: (state, player-y) ->
    if state.UP   then player-y -= kHalfTile / 2
    if state.DOWN then player-y += kHalfTile / 2
    player-y + @gun-bob state

  gun-bob: (state) ->
    if state.WALKING and (state.STRIDE_LEFT or state.STRIDE_RIGHT) then -2 else 0

  get-projectiles: ->
    projectiles = []
    if @projectile-a then projectiles.push that
    if @projectile-b then projectiles.push that
    return projectiles

  # Update methods

  update-projectiles: (elapsed-time, map) ->
    if not @projectile-a?.update elapsed-time, map
      @projectile-a = null

    if not @projectile-b?.update elapsed-time, map
      @projectile-b = null

  draw: (graphics, player-x, player-y, state) ->
    gun-x = @gun-x state, player-x
    gun-y = @gun-y state, player-y

    @sprites[ state.key ].draw graphics, gun-x, gun-y

    @projectile-a?.draw graphics
    @projectile-b?.draw graphics

