
#
# Player
#

require! \std
require! \./units
require! \./config
require! \./readout

{ kHalfTile, tile-to-game, tile-to-px } = units

{ SpriteState, State } = require \./spritestate

{ WALL_TILE }       = require \./map
{ Rectangle: Rect } = require \./rectangle
{ Timer }           = require \./timer
{ Health }          = require \./health
{ DamageText }      = require \./damage-text
{ PolarStar }       = require \./arms
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


# Player class

export class Player

  # Player (Game, Game) - Initial position - constructor

  (graphics, @x, @y) ->

    # Player state (excluding x and y)
    @velocity-y        = 0
    @velocity-x        = 0
    @acceleration-x    = 0
    @horizontal-facing = State.LEFT
    @vertical-facing   = State.HORIZONTAL
    @on-ground         = no
    @jump-active       = no
    @interacting       = no

    # Timers
    @invincible-timer = new Timer kInvincibleTime

    # HUD
    @health = new Health graphics

    # Sprites
    @sprites = @initialise-sprites graphics
    @damage-text = new DamageText graphics

    # Items
    @gun = new PolarStar graphics

  initialise-sprites: (graphics, sprite-map = {}) ->
    SpriteState.generate-with (state) ->
      tile-x = switch true
        | state.WALKING     => kWalkFrame
        | state.STANDING    => kStandFrame
        | state.JUMPING     => kJumpFrame
        | state.FALLING     => kFallFrame
        | state.INTERACTING => kBackFrame
        | _ => void

      tile-x += if state.UP then kUpFrameOffset else 0
      tile-y = kCharacterFrame + if state.LEFT then 0 else 1

      if state.WALKING
        new AnimatedSprite graphics, 'data/16x16/MyChar.bmp',
          units.tile-to-px(tile-x), units.tile-to-px(tile-y),
          units.tile-to-px(1), units.tile-to-px(1),
          kWalkFps, 3, [ 0, 1, 0, 2 ]
      else
        if state.DOWN and (state.JUMPING or state.FALLING)
          source-x = kDownFrame

        new Sprite graphics, 'data/16x16/MyChar.bmp',
          units.tile-to-px(tile-x), units.tile-to-px(tile-y),
          units.tile-to-px(1), units.tile-to-px(1)

  update: (elapsed-time, map) ->
    @sprites[@get-sprite-state!key].update elapsed-time
    @health.update elapsed-time
    @update-x elapsed-time, map
    @update-y elapsed-time, map
    @damage-text.update elapsed-time

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

  take-damage: (damage = 1) ->
    unless @invincible-timer.is-active!
      @health.take-damage damage
      @velocity-y = std.min -kShortJumpSpeed, @velocity-y
      @invincible = yes
      @invincible-timer.reset!
      @damage-text.set-damage damage

  sprite-is-visible: ->
    duty = @invincible-timer.current-time `std.div` kInvincibleFlashTime % 2 is 0
    return not (@invincible-timer.is-active! and duty)


  # Draw

  draw: (graphics) ->
    if @sprite-is-visible!
      state = @get-sprite-state!
      @gun.draw graphics, @x, @y, state
      @sprites[state.key].draw graphics, @x, @y
    @damage-text.draw graphics, @center-x!, @center-y!

  draw-hud: (graphics) ->
    return unless @sprite-is-visible!
    @health.draw graphics

  get-sprite-state: ->
    motion-type =
      if @interacting
        State.INTERACTING
      else if @on-ground
        if @acceleration-x is 0 then State.STANDING else State.WALKING
      else
        if @velocity-y < 0 then State.JUMPING else State.FALLING
    SpriteState.make @horizontal-facing, @vertical-facing, motion-type


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
    @horizontal-facing = State.LEFT
    @acceleration-x = -1
    @interacting = no

  start-moving-right: ->
    @horizontal-facing = State.RIGHT
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
    @vertical-facing = State.UP
    @interacting = no

  look-down: ->
    return if @vertical-facing is State.DOWN
    @vertical-facing = State.DOWN
    @interacting = @on-ground

  look-horizontal: ->
    @vertical-facing = State.HORIZONTAL


  # Misc getter
  center-x: -> @x + kHalfTile
  center-y: -> @y + kHalfTile

