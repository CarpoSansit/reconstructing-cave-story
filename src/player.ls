
#
# Player
#

require! \std
require! \./units
require! \./config
require! \./readout


{ kHalfTile, tile-to-game, tile-to-px } = units

{ WALL_TILE }       = require \./map
{ Rectangle: Rect } = require \./rectangle
{ Health }          = require \./health
{ Sprite, AnimatedSprite, NumberSprite } = require \./sprite


# Animation constants
kCharacterFrame = 0
kWalkFrame      = 0
kStandFrame     = 0
kJumpFrame      = 1
kFallFrame      = 2
kUpFrameOffset  = 3
kDownFrame      = 6
kBackFrame      = 7
kWalkFps        = 15

# Physics constants
kFriction            = 0.00049804687
kGravity             = 0.00078125
kWalkingAcceleration = 0.00083007812
kAirAcceleration     = 0.0003125
kMaxSpeedX           = 0.15859375
kMaxSpeedY           = 0.2998046875
kJumpSpeed           = 0.25
kShortJumpSpeed      = 0.25 / 1.5
kJumpGravity         = 0.0003125

# Time constants
kInvincibleTime      = 3000
kInvincibleFlashTime = 50

# Collision boxes
kCollisionX = new Rect 6, 10, 20, 12
kCollisionY = new Rect 10, 2, 12, 30

# For these, I'm using strings instead of numbers because it makes
# the debug readout much easier to understand. If this has performance
# implications later on I'll put it back.
[ STANDING, WALKING, JUMPING, FALLING, INTERACTING ] = <[ S W J F I ]>
[ LEFT, RIGHT ] = <[ L R ]>
[ UP, DOWN, HORIZONTAL ] = <[ U D H ]>


# Private class: SpriteState

class SpriteState
  ( @motion-type       = STANDING,
    @horizontal-facing = LEFT,
    @vertical-facing   = HORIZONTAL ) ->

  key: ->
    "#{@motion-type}-#{@horizontal-facing}-#{@vertical-facing}"

  @key = (...args) ->
    args.join '-'


# Player class

export class Player

  # Player (Game, Game) - Initial position - constructor

  (graphics, @x, @y) ->

    # Player state (excluding x and y)
    @velocity-y        = 0
    @velocity-x        = 0
    @acceleration-x    = 0
    @horizontal-facing = LEFT
    @vertical-facing   = HORIZONTAL
    @on-ground         = no
    @jump-active       = no
    @interacting       = no
    @invincible        = no

    # Timers
    @invincible-time = 0

    # HUD
    @health = new Health graphics

    # Sprite management
    @sprites = @initialise-sprites graphics

    # Debug
    if config.kDebugMode
      readout.add-reader \spritestate, 'SpriteState'

  initialise-sprite: (graphics, motion, hfacing, vfacing) ->
    tile-x =
      switch motion
      | WALKING     => kWalkFrame
      | STANDING    => kStandFrame
      | JUMPING     => kJumpFrame
      | FALLING     => kFallFrame
      | INTERACTING => kBackFrame
      | _ => void

    tile-x += if vfacing is UP then kUpFrameOffset else 0

    tile-y = kCharacterFrame + if hfacing is LEFT then 0 else 1

    if motion is WALKING
      new AnimatedSprite graphics, 'data/16x16/MyChar.bmp',
        units.tile-to-px(tile-x), units.tile-to-px(tile-y),
        units.tile-to-px(1), units.tile-to-px(1),
        kWalkFps, 3
    else
      if vfacing is DOWN and (motion is JUMPING or motion is FALLING)
        source-x = kDownFrame

      new Sprite graphics, 'data/16x16/MyChar.bmp',
        units.tile-to-px(tile-x), units.tile-to-px(tile-y),
        units.tile-to-px(1), units.tile-to-px(1)

  initialise-sprites: (graphics, sprite-map = {}) ->
    for motion in [ STANDING, WALKING, JUMPING, FALLING, INTERACTING ]
      for hfacing in [ LEFT, RIGHT ]
        for vfacing in [ UP, DOWN, HORIZONTAL ]
          sprite-map[ SpriteState.key motion, hfacing, vfacing ] =
            @initialise-sprite graphics, motion, hfacing, vfacing
    return sprite-map

  update: (elapsed-time, map) ->
    @sprites[@get-sprite-state!].update elapsed-time

    if @invincible
      @invincible-time += elapsed-time
      @invincible = @invincible-time < kInvincibleTime

    @health.update elapsed-time
    @update-x elapsed-time, map
    @update-y elapsed-time, map


  update-x: (elapsed-time, map) ->
    acc-x = if @on-ground then kWalkingAcceleration else kAirAcceleration
    @velocity-x += @acceleration-x * acc-x * elapsed-time

    if @acceleration-x < 0
      @velocity-x = std.max(@velocity-x, -kMaxSpeedX);
    else if @acceleration-x > 0
      @velocity-x = std.min(@velocity-x, kMaxSpeedX);
    else if @on-ground
      @velocity-x =
        if @velocity-x > 0
          std.max 0, @velocity-x - kFriction * elapsed-time
        else
          std.min 0, @velocity-x + kFriction * elapsed-time

    Δx = @velocity-x * elapsed-time

    if Δx > 0
      @on-wall-collision map, (@right-collision Δx), (tile) ->
        if tile
          @x = units.tile-to-game(tile.col) - kCollisionX.right
          @velocity-x = 0
        else
          @x += Δx

      @on-wall-collision map, (@left-collision 0), (tile) ->
        if tile
          @x = units.tile-to-game(tile.col) + kCollisionX.right

    else
      @on-wall-collision map, (@left-collision Δx), (tile) ->
        if tile
          @x = units.tile-to-game(tile.col) + kCollisionX.right
          @velocity-x = 0
        else
          @x += Δx

      @on-wall-collision map, (@right-collision 0), (tile) ->
        if tile
          @x = units.tile-to-game(tile.col) - kCollisionX.right


  update-y: (elapsed-time, map) ->
    gravity = if @jump-active and @velocity-y < 0 then kJumpGravity else kGravity
    @velocity-y = std.min @velocity-y + gravity * elapsed-time, kMaxSpeedY

    Δy = @velocity-y * elapsed-time

    # Falling
    if Δy > 0
      @on-wall-collision map, (@bottom-collision Δy), (tile) ->
        if tile
          @y = units.tile-to-game(tile.row) - kCollisionY.bottom
          @velocity-y = 0
          @on-ground = yes
        else
          @y += Δy
          @on-ground = no

      @on-wall-collision map, (@top-collision 0), (tile) ->
        if tile
          @y = units.tile-to-game(tile.row) + kCollisionY.h

    # Jumping
    else
      @on-wall-collision map, (@top-collision Δy), (tile) ->
        if tile
          @y = units.tile-to-game(tile.row) + kCollisionY.h
          @velocity-y = 0
        else
          @y += Δy
          @on-ground = no

      @on-wall-collision map, (@bottom-collision 0), (tile) ->
        if tile
          @y = units.tile-to-game(tile.row) - kCollisionY.bottom
          @on-ground = yes

  take-damage: (damage) ->
    unless @invincible
      @health.take-damage 2
      @velocity-y = std.min -kShortJumpSpeed, @velocity-y
      @invincible = yes
      @invincible-time = 0

  sprite-is-visible: ->
    not (@invincible and @invincible-time `std.div` kInvincibleFlashTime % 2 is 0)

  draw-hud: (graphics) ->
    return unless @sprite-is-visible!
    @health.draw graphics

  draw: (graphics) ->
    return unless @sprite-is-visible!
    #graphics.visualiseRect @damage-collision!, no
    @sprites[@get-sprite-state!].draw graphics, @x, @y

  get-sprite-state: ->
    motion-type =
      if @interacting
        INTERACTING
      else if @on-ground
        if @acceleration-x is 0 then STANDING else WALKING
      else
        if @velocity-y < 0 then JUMPING else FALLING
    key = SpriteState.key motion-type, @horizontal-facing, @vertical-facing
    readout.update \spritestate, key
    return key


  # Collision spaces

  left-collision: (Δ) -> # Δ <= 0
    new Rect @x + kCollisionX.left + Δ, @y + kCollisionX.top,
      kCollisionX.w/2 - Δ, kCollisionX.h

  right-collision: (Δ) -> # Δ >= 0
    new Rect @x + kCollisionX.left + kCollisionX.w/2,
      @y + kCollisionX.top,
      kCollisionX.w/2 + Δ, kCollisionX.h

  top-collision: (Δ) ->
    new Rect @x + kCollisionY.left, @y + kCollisionY.top + Δ,
      kCollisionY.w, kCollisionY.h/2 - Δ

  bottom-collision: (Δ) ->
    new Rect @x + kCollisionY.left,
      @y + kCollisionY.top + kCollisionY.h/2 + Δ
      kCollisionY.w, kCollisionY.h/2 + Δ

  damage-collision: ->
    new Rect @x + kCollisionX.left, @y + kCollisionY.top,
      kCollisionX.w, kCollisionY.h

  on-wall-collision: (map, rect, λ) ->
    for tile in map.get-colliding-tiles rect
      if tile.type is WALL_TILE
        return λ.call this, tile
    λ.call this


  # Button handlers

  start-moving-left: ->
    @horizontal-facing = LEFT
    @acceleration-x = -1
    @interacting = no

  start-moving-right: ->
    @horizontal-facing = RIGHT
    @acceleration-x = 1
    @interacting = no

  stop-moving: ->
    @acceleration-x = 0

  start-jump: ->
    @jump-active = yes
    @interacting = no
    @velocity-y = -kJumpSpeed if @on-ground

  stop-jump: ->
    @jump-active = no

  look-up: ->
    @vertical-facing = UP
    @interacting = no

  look-down: ->
    return if @vertical-facing is DOWN
    @vertical-facing = DOWN
    @interacting = @on-ground

  look-horizontal: ->
    @vertical-facing = HORIZONTAL

