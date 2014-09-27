
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
{ Timer }           = require \./timer
{ Health }          = require \./health
{ Damageable }      = require \./damageable
{ DamageText }      = require \./damage-text
{ DamageTexts }     = require \./damage-texts
{ PolarStar }       = require \./arms

{ SpriteState, State } = require \./spritestate
{ Sprite, AnimatedSprite, NumberSprite } = require \./sprite

{ HeadBumpParticle } = require \./head-bump-particle

# Animation constants
kCharacterFrame = 0
kWalkFrame      = 0
kStandFrame     = 0
kJumpFrame      = 1
kFallFrame      = 2
kUpFrameOffset  = 3
kDownFrame      = 6
kBackFrame      = 7
kNumWalkFrames  = 3
kWalkFps        = 15

kStrideMiddleFrameOffset = 0
kStrideLeftFrameOffset   = 1
kStrideRightFrameOffset  = 2

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

kCollisionYTop         = 2
kCollisionYHeight      = 30
kCollisionYTopWidth    = 18
kCollisionYBottomWidth = 10
kCollisionYTopLeft     = (tile-to-game(1) - kCollisionYTopWidth) / 2
kCollisionYBottomLeft  = (tile-to-game(1) - kCollisionYBottomWidth) / 2
kCollisionYBottom      = kCollisionYTop + kCollisionYHeight


# Private class: WalkingAnimation

class WalkingAnimation

  (@num-frames, @fps) ->
    @frame-timer = new Timer 1000 / @fps
    @forward     = true
    @index       = 0

  stride: ->
    switch @index
    | 0 => State.STRIDE_LEFT
    | 1 => State.STRIDE_MIDDLE
    | 2 => State.STRIDE_RIGHT
    | _ => State.STRIDE_LEFT

  update: ->
    if @frame-timer.is-expired
      @frame-timer.reset!

      if @forward
        @index += 1
        @forward = @index isnt @num-frames - 1
      else
        @index -= 1
        @forward = @index is 0

  reset: ->
    @frame-timer.reset!
    @index = 0
    @forward = true


# Player class

export class Player extends Damageable

  # Player (Game, Game) - Initial position - constructor

  (graphics, @x, @y) ->

    # Player state (excluding x and y)
    @velocity-y        = 0
    @velocity-x        = 0
    @acceleration-x    = 0
    @horizontal-facing = State.LEFT
    @intended-vertical-facing   = State.HORIZONTAL
    @on-ground         = no
    @jump-active       = no
    @interacting       = no

    # Animation sync
    @walk-animation = new WalkingAnimation kNumWalkFrames, kWalkFps

    # Timers
    @invincible-timer = new Timer kInvincibleTime

    # HUD
    @health = new Health graphics

    # Sprites
    @sprites = @initialise-sprites graphics
    @damage-text = new DamageText graphics

    DamageTexts.add-damageable this

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
        | otherwise => void

      if state.UP   then tile-x += kUpFrameOffset
      if state.DOWN then tile-x = kDownFrame

      tile-y = kCharacterFrame + if state.LEFT then 0 else 1

      if state.WALKING
        tile-x += switch true
          | state.STRIDE_LEFT   => kStrideLeftFrameOffset
          | state.STRIDE_RIGHT  => kStrideRightFrameOffset
          | state.STRIDE_MIDDLE => kStrideMiddleFrameOffset
          | otherwise => void
        new Sprite graphics, \MyChar,
          units.tile-to-px(tile-x), units.tile-to-px(tile-y),
          units.tile-to-px(1), units.tile-to-px(1)
      else
        new Sprite graphics, \MyChar,
          units.tile-to-px(tile-x), units.tile-to-px(tile-y),
          units.tile-to-px(1), units.tile-to-px(1)

  update: (elapsed-time, map, ptools) ->
    @sprites[@get-sprite-state!key].update elapsed-time
    @health.update elapsed-time
    @gun.update-projectiles elapsed-time, map
    @update-x elapsed-time, map
    @update-y elapsed-time, map, ptools
    @walk-animation.update elapsed-time

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


  update-y: (elapsed-time, map, ptools) ->
    gravity = if @jump-active and @velocity-y < 0 then kJumpGravity else kGravity
    @velocity-y = std.min @velocity-y + gravity * elapsed-time, kMaxSpeedY

    Δy = @velocity-y * elapsed-time

    # Falling
    if Δy > 0
      @on-wall-collision map, (@bottom-collision Δy), (tile) ->
        if tile
          @y = units.tile-to-game(tile.row) - kCollisionYBottom
          @velocity-y = 0
          @on-ground = yes
        else
          @y += Δy
          @on-ground = no

      @on-wall-collision map, (@top-collision 0), (tile) ->
        if tile
          @y = units.tile-to-game(tile.row) + kCollisionYHeight

    # Jumping
    else
      @on-wall-collision map, (@top-collision Δy), (tile) ->
        if tile
          @y = units.tile-to-game(tile.row) + kCollisionYHeight
          @velocity-y = 0
          ptools.system.add-new-particle new HeadBumpParticle ptools.graphics,
            @center-x, @y + kCollisionYTop
        else
          @y += Δy
          @on-ground = no

      @on-wall-collision map, (@bottom-collision 0), (tile) ->
        if tile
          @y = units.tile-to-game(tile.row) - kCollisionYBottom
          @on-ground = yes

  take-damage: (damage = 1) ->
    unless @invincible-timer.is-active
      @health.take-damage damage
      @velocity-y = std.min -kShortJumpSpeed, @velocity-y
      @invincible = yes
      @invincible-timer.reset!
      @damage-text.set-damage damage

  sprite-is-visible: ->
    duty = @invincible-timer.current-time `std.div` kInvincibleFlashTime % 2 is 0
    return not (@invincible-timer.is-active and duty)


  # Drawing

  draw: (graphics) ->
    if config.show-collisions
      graphics.visualise-rect @damage-collision!
    if @sprite-is-visible!
      state = @get-sprite-state!
      @gun.draw graphics, @x, @y, state
      @sprites[state.key].draw graphics, @x, @y

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
    SpriteState.make @horizontal-facing, @vertical-facing!,
      motion-type, @walk-animation.stride!


  # Collision spaces

  left-collision: (Δ) -> # Δ <= 0
    new Rect @x + kCollisionX.left + Δ, @y + kCollisionX.top,
      kCollisionX.w/2 - Δ, kCollisionX.h

  right-collision: (Δ) -> # Δ >= 0
    new Rect @x + kCollisionX.left + kCollisionX.w/2,
      @y + kCollisionX.top,
      kCollisionX.w/2 + Δ, kCollisionX.h

  top-collision: (Δ) ->
    new Rect @x + kCollisionYTopLeft, @y + kCollisionYTop + Δ,
      kCollisionYTopWidth, kCollisionYHeight/2 - Δ

  bottom-collision: (Δ) ->
    new Rect @x + kCollisionYBottomLeft,
      @y + kCollisionYTop + kCollisionYHeight/2 + Δ
      kCollisionYBottomWidth, kCollisionYHeight/2 + Δ

  damage-collision: ->
    new Rect @x + kCollisionX.left, @y + kCollisionYTop,
      kCollisionX.w, kCollisionYHeight

  on-wall-collision: (map, rect, λ) ->
    for tile in map.get-colliding-tiles rect
      if tile.type is WALL_TILE
        return λ.call this, tile
    λ.call this


  # Button handlers

  start-moving-left: ->
    if @on-ground and @acceleration-x is 0 then @walk-animation.reset!
    @horizontal-facing = State.LEFT
    @acceleration-x = -1
    @interacting = no

  start-moving-right: ->
    if @on-ground and @acceleration-x is 0 then @walk-animation.reset!
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

  start-fire: ->
    @gun.start-fire @get-sprite-state!, @x, @y

  stop-fire: ->
    @gun.stop-fire!

  look-up: ->
    @intended-vertical-facing = State.UP
    @interacting = no

  look-down: ->
    return if @intended-vertical-facing is State.DOWN
    @intended-vertical-facing = State.DOWN
    @interacting = @on-ground

  look-horizontal: ->
    @intended-vertical-facing = State.HORIZONTAL


  # Damageable getters
  center-x:~ -> @x + kHalfTile
  center-y:~ -> @y + kHalfTile
  get-damage-text: -> @damage-text

  # Misc getters
  get-projectiles: ->
    @gun.get-projectiles!

  vertical-facing: ->
    if @on-ground and @intended-vertical-facing is State.DOWN
      State.HORIZONTAL
    else
      @intended-vertical-facing

