
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
{ SpriteState, State } = require \./spritestate
{ Projectile }         = require \./projectile
{ StarParticle }       = require \./star-particle
{ WallParticle }       = require \./wall-particle

{ Rectangle: Rect, SpriteSource } = require \./rectangle


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
kProjectileSrcHorizontal = new SpriteSource 8, 2, 1, 1
kProjectileSrcVertical   = new SpriteSource 9, 2, 1, 1

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

# Firing direction modes

[ UP, DOWN, LEFT, RIGHT ] = std.enum


# Private Class: Projectile

class PolarStarProjectile extends Projectile
  (@sprite, state, x, y) ->
    super 1

    @offset   = 0
    @lifespan = kL1Lifespan
    @alive    = yes

    std.log 'SFX: Pew!'

    if state.HORIZONTAL
      @width  = kL1CollisionWidth
      @height = kL1CollisionHeight
      @vertical = no
    else
      @width  = kL1CollisionHeight
      @height = kL1CollisionWidth
      @vertical = yes

    # Just so we can get it later
    @mode = switch true
    | state.UP    => UP
    | state.DOWN  => DOWN
    | state.LEFT  => LEFT
    | state.RIGHT => RIGHT

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

  update: (elapsed-time, map, ptools) ->
    @offset += kL1Speed * elapsed-time

    for tile in map.get-colliding-tiles @collision-rectangle!
      if tile.type is WALL_TILE
        tile-rect = new Rect tile-to-game(tile.col), tile-to-game(tile.row),
          tile-to-game(1), tile-to-game(1)

        particle-x = @x
        particle-y = @y

        switch @mode
        | UP =>    particle-y = tile-rect.bottom - kHalfTile
        | DOWN =>  particle-y = tile-rect.top - kHalfTile
        | LEFT =>  particle-x = tile-rect.right - kHalfTile
        | RIGHT => particle-x = tile-rect.left - kHalfTile

        ptools.system.add-new-particle new WallParticle ptools.graphics,
          particle-x, particle-y

        # Die (as a function AND as a particle) before end of for loop
        return false

    # Report status
    if not @alive
      false
    else if @offset >= @lifespan
      ptools.system.add-new-particle new StarParticle ptools.graphics, @x, @y
      false
    else
      true

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

    @hp-sprite = new Sprite graphics, \bullet, kProjectileSrcHorizontal
    @vp-sprite = new Sprite graphics, \bullet, kProjectileSrcVertical

  initialise-sprites: (graphics) ->
    SpriteState.generate-with (state) ->
      tile-y = if state.LEFT then kLeftOffset else kRightOffset

      switch true
      | state.HORIZONTAL => tile-y += kHorizontalOffset
      | state.UP         => tile-y += kUpOffset
      | state.DOWN       => tile-y += kDownOffset

      new Sprite graphics, kArmsSpritePath,
        new SpriteSource kPolarStarIndex * kSpriteWidth,
          tile-y, kSpriteWidth, kSpriteHeight

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

  update-projectiles: (elapsed-time, map, ptools) ->
    if not @projectile-a?.update elapsed-time, map, ptools
      @projectile-a = null

    if not @projectile-b?.update elapsed-time, map, ptools
      @projectile-b = null

  draw: (graphics, player-x, player-y, state) ->
    gun-x = @gun-x state, player-x
    gun-y = @gun-y state, player-y

    @sprites[ state.key ].draw graphics, gun-x, gun-y

    @projectile-a?.draw graphics
    @projectile-b?.draw graphics

