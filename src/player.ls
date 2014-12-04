
#
# Player
#

require! \std
require! \./units
require! \./config
require! \./readout

{ kHalfTile, tile-to-game, tile-to-px: tpx } = units

{ Timer }              = require \./timer
{ Health }             = require \./health
{ Pickup }             = require \./pickup
{ Kinematics }         = require \./kinematics
{ Damageable }         = require \./damageable
{ DamageText }         = require \./damage-text
{ DamageTexts }        = require \./damage-texts
{ PolarStar }          = require \./arms
{ GunExperienceHUD }   = require \./gun-xp-hud
{ MapCollidable }      = require \./map-collidable
{ SpriteState, State } = require \./spritestate
{ Rectangle: Rect }    = require \./rectangle
{ HeadBumpParticle }   = require \./head-bump-particle

{ CompositeCollisionRectangle } = require \./collision-rectangle
{ ConstantAccelerator, FrictionAccelerator, BidirectionalAccelerator,
kZero, kGravity, kTerminalSpeed } = require \./accelerators

{ Side } = require \./map-collidable
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
kNumWalkFrames  = 3
kWalkFps        = 15

kStrideMiddleFrameOffset = 0
kStrideLeftFrameOffset   = 1
kStrideRightFrameOffset  = 2

# Physics
kJumpSpeed      = 0.25
kShortJumpSpeed = kJumpSpeed / 1.5
kMaxSpeedX      = 0.15859375
kWalkAcc        = new BidirectionalAccelerator 0.00083007812, kMaxSpeedX
kAirAcc         = new BidirectionalAccelerator 0.0003125, kMaxSpeedX
kGravityAcc     = new ConstantAccelerator kGravity, kTerminalSpeed
kFrictionAcc    = new FrictionAccelerator 0.00049804687
kJumpGravityAcc = new ConstantAccelerator 0.0003125, kTerminalSpeed

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

kCollisionRectangle = new CompositeCollisionRectangle(
  new Rect kCollisionYTopLeft, kCollisionYTop, kCollisionYTopWidth, kCollisionYHeight / 2
  new Rect kCollisionYBottomLeft, kCollisionYTop + kCollisionYHeight/2, kCollisionYBottomWidth, kCollisionYHeight / 2
  new Rect 6, 10, 10, 12
  new Rect 16, 10, 10, 12
)


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

export class Player implements Damageable::, MapCollidable::

  # Player (Game, Game) - Initial position - constructor

  (graphics, x, y, @ptools) ->

    readout.add-reader \player-pos, \Player

    # Player state (excluding x and y)
    @acceleration-x    = 0
    @horizontal-facing = State.LEFT
    @intended-vertical-facing = State.HORIZONTAL
    @on-ground         = no
    @jump-active       = no
    @interacting       = no

    # Kinematics
    @kinematics-x = new Kinematics x, 0
    @kinematics-y = new Kinematics y, 0

    # Animation sync
    @walk-animation = new WalkingAnimation kNumWalkFrames, kWalkFps

    # Timers
    @invincible-timer = new Timer kInvincibleTime

    # HUD
    @health = new Health graphics
    @gun-hud = new GunExperienceHUD graphics

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

      new Sprite graphics, \MyChar, tpx(tile-x), tpx(tile-y), tpx(1), tpx(1)

  update: (elapsed-time, map) ->
    @health.update!
    @walk-animation.update elapsed-time
    @gun.update-projectiles elapsed-time, map, @ptools

    readout.update \player-pos, "#{std.round @center-x},#{std.round @center-y}"

    # updateX
    acc-x =
      if @on-ground
        if @acceleration-x is 0
          kFrictionAcc
        else if @acceleration-x < 0
          kWalkAcc.negative
        else
          kWalkAcc.positive
      else
        if @acceleration-x is 0
          kZero
        else if @acceleration-x < 0
          kAirAcc.negative
        else
          kAirAcc.positive

    @update-x kCollisionRectangle, acc-x,
      @kinematics-x, @kinematics-y, elapsed-time, map

    # updateY
    acc-y =
      if @jump-active and @kinematics-y.velocity < 0 then
        kJumpGravityAcc
      else
        kGravityAcc

    @update-y kCollisionRectangle, acc-y,
      @kinematics-x, @kinematics-y, elapsed-time, map

  take-damage: (damage = 1) ->
    unless @invincible-timer.is-active
      @health.take-damage damage
      @kinematics-y.velocity = std.min -kShortJumpSpeed, @kinematics-y.velocity
      @invincible = yes
      @invincible-timer.reset!
      @damage-text.set-damage damage

  collect-pickup: (pickup) ->
    std.log 'SFX: Ding!'
    std.log pickup, Pickup.EXPERIENCE
    if pickup.type is Pickup.EXPERIENCE
      @gun.collect-experience pickup.value
      @gun-hud.activate-flash!

  sprite-is-visible: ->
    duty = @invincible-timer.current-time `std.div` kInvincibleFlashTime % 2 is 0
    return not (@invincible-timer.is-active and duty)


  # Drawing

  draw: (graphics) ->
    if config.show-collisions
      graphics.visualise-rect @damage-collision!
    if @sprite-is-visible!
      state = @get-sprite-state!
      @gun.draw graphics, @kinematics-x.position, @kinematics-y.position, state
      @sprites[state.key].draw graphics, @kinematics-x.position, @kinematics-y.position

  draw-hud: (graphics) ->
    return unless @sprite-is-visible!
    @gun.draw-hud graphics, @gun-hud
    @health.draw graphics

  get-sprite-state: ->
    motion-type =
      if @interacting
        State.INTERACTING
      else if @on-ground
        if @acceleration-x is 0 then State.STANDING else State.WALKING
      else
        if @kinematics-y.velocity < 0 then State.JUMPING else State.FALLING
    SpriteState.make @horizontal-facing, @vertical-facing!,
      motion-type, @walk-animation.stride!


  # MapCollidable

  on-collision: (side, is-delta-direction) ->
    switch side
    | Side.TOP =>
      if is-delta-direction
        @kinematics-y.velocity = 0
      @ptools.front-system.add-new-particle new HeadBumpParticle @ptools.graphics,
        @center-x, @kinematics-y.position + kCollisionRectangle.bounding-box.top
    | Side.BOTTOM =>
      @on-ground = true
      if is-delta-direction
        @kinematics-y.velocity = 0
    | Side.LEFT =>
      if is-delta-direction
        @kinematics-x.velocity = 0
    | Side.RIGHT  =>
      if is-delta-direction
        @kinematics-x.velocity = 0

  on-delta: (side) ->
    switch side
    | Side.TOP =>
      @on-ground = false
    | Side.BOTTOM =>
      @on-ground = false
    | Side.LEFT =>
    | Side.RIGHT =>

  damage-collision: ->
    kCollisionRectangle.bounding-box.translate @kinematics-x.position, @kinematics-y.position


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
    @kinematics-y.velocity = -kJumpSpeed if @on-ground

  stop-jump: ->
    @jump-active = no

  start-fire: ->
    @gun.start-fire @get-sprite-state!, @kinematics-x.position, @kinematics-y.position

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

  # Damageable
  center-x:~ -> @kinematics-x.position + kHalfTile
  center-y:~ -> @kinematics-y.position + kHalfTile
  get-damage-text: -> @damage-text

  # Misc getters
  get-projectiles: ->
    @gun.get-projectiles!

  vertical-facing: ->
    if @on-ground and @intended-vertical-facing is State.DOWN
      State.HORIZONTAL
    else
      @intended-vertical-facing

