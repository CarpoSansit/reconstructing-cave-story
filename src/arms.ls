
#
# Arms
#
# All the different guns
#


require! \std
require! \./units
require! \./config

{ kHalfTile, tile-to-px:tpx, tile-to-game, game-to-px } = units

{ WALL_TILE }          = require \./map
{ Sprite }             = require \./sprite
{ SpriteState, State } = require \./spritestate
{ Projectile }         = require \./projectile
{ StarParticle }       = require \./star-particle
{ WallParticle }       = require \./wall-particle

{ Rectangle: Rect } = require \./rectangle


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

# Projectile sprite sources
kProjectileSrcYs = [ 2, 2, 3 ]
kProjectileSrcXs = [ 8, 10, 8 ]

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
kLifespans        = [ tile-to-game(3.5), tile-to-game(5), tile-to-game(7) ]
kSpeeds           = [ 0.6, 0.6, 0.6 ]
kCollisionWidths  = [ 32, 32, 32 ]
kCollisionHeights = [ 4, 8, 16 ]
kDamages          = [ 1, 2, 4 ]

# Firing direction modes

[ UP, DOWN, LEFT, RIGHT ] = std.enum


# Private Class: Projectile

class PolarStarProjectile extends Projectile
  (@sprite, state, x, y, @gun-level) ->
    super kDamages[@gun-level - 1]

    @offset   = 0
    @lifespan = kLifespans[@gun-level - 1]
    @alive    = yes

    std.log 'SFX: Pew!'

    if state.HORIZONTAL
      @width  = kCollisionWidths[@gun-level - 1]
      @height = kCollisionHeights[@gun-level - 1]
      @vertical = no
    else
      @width  = kCollisionHeights[@gun-level - 1]
      @height = kCollisionWidths[@gun-level - 1]
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
    new Rect @x + kHalfTile - @width / 2,
      @y + kHalfTile - @height / 2,
      @width, @height

  update: (elapsed-time, map, ptools) ->
    @offset += kSpeeds[@gun-level - 1] * elapsed-time

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

        ptools.front-system.add-new-particle new WallParticle ptools.graphics,
          particle-x, particle-y

        # Die (as a function AND as a particle) before end of for loop
        return false

    # Report status
    if not @alive
      false
    else if @offset >= @lifespan
      ptools.front-system.add-new-particle new StarParticle ptools.graphics, @x, @y
      false
    else
      true

  draw: (graphics) ->
    @sprite.draw graphics, @x, @y
    if config.show-collisions
      graphics.visualiseRect @collision-rectangle!

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
    @current-level = 1

    @hp-sprites =
      for lvl from 0 to units.kMaxGunLevel
        new Sprite graphics, \bullet,
          tpx(kProjectileSrcXs[lvl]), tpx(kProjectileSrcYs[lvl]), tpx(1), tpx(1)

    @vp-sprites =
      for lvl from 0 to units.kMaxGunLevel
        new Sprite graphics, \bullet,
          tpx(kProjectileSrcXs[lvl]+1), tpx(kProjectileSrcYs[lvl]), tpx(1), tpx(1)

  initialise-sprites: (graphics) ->
    SpriteState.generate-with (state) ->
      tile-y = if state.LEFT then kLeftOffset else kRightOffset

      switch true
      | state.HORIZONTAL => tile-y += kHorizontalOffset
      | state.UP         => tile-y += kUpOffset
      | state.DOWN       => tile-y += kDownOffset

      new Sprite graphics, kArmsSpritePath,
        tpx(kPolarStarIndex * kSpriteWidth),
          tpx(tile-y), tpx(kSpriteWidth), tpx(kSpriteHeight)

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
    sprite =
      if state.HORIZONTAL
        @hp-sprites[@current-level - 1]
      else
        @vp-sprites[@current-level - 1]

    if not @projectile-a
      @projectile-a =
        new PolarStarProjectile sprite, state, bullet-x, bullet-y, @current-level

    else if not @projectile-b
      @projectile-b =
        new PolarStarProjectile sprite, state, bullet-x, bullet-y, @current-level

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

  draw-hud: (graphics, hud) ->
    hud.draw graphics, @current-level, 0, 10

