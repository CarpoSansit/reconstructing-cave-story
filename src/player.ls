
# Require

require! \std
require! \./graphics

Game           = require \./game
Sprite         = require \./sprite
AnimatedSprite = require \./animated-sprite


# Animation constants
kSpriteFrameTime     = 15

# Physics constants
kSlowdownFactor      = 0.8
kWalkingAcceleration = 0.0012
kMaxSpeedX           = 0.325
kMaxSpeedY           = 0.325
kJumpSpeed           = 0.325
kJumpTime            = 275
kJumpFrame           = 1
kFallFrame           = 2
kGravity             = 0.0012

# Enumerated constants
[ STANDING, WALKING, JUMPING, FALLING ] = std.enum
[ LEFT, RIGHT ] = std.enum


# Private class: SpriteState
class SpriteState
  (@motion-type = STANDING, @horizontal-facing = LEFT) ->
  key: -> "#{@motion-type}-#{@horizontal-facing}"
  @key = (...args) -> args.join '-'

# Private class: Jump
class Jump
  ->
    @time-remaining = 0ms
    @active         = no

  update: (elapsed-time) ->
    if @active
      @time-remaining -= elapsed-time
      if @time-remaining <= 0
        @active = no

  reset: ->
    @time-remaining = kJumpTime
    @reactivate!

  reactivate: ->
    @active = @time-remaining > 0

  deactivate: ->
    @active = no


# Player class
module.exports = class Player

  (@x, @y) ->

    # Player state (excluding x and y)
    @velocity-y        = 0
    @velocity-x        = 0
    @acceleration-x    = 0
    @horizontal-facing = LEFT
    @on-ground         = no

    # Helper instances
    @jump = new Jump

    # Sprite management
    @sprite-state = new SpriteState STANDING, LEFT
    @sprites = @initialise-sprites!

  initialise-sprites: (sprite-map = {}) ->

    "#{SpriteState.key( STANDING, LEFT )}":
      new Sprite graphics, 'content/MyChar.bmp',
        0, 0, Game.kTileSize, Game.kTileSize

    "#{SpriteState.key( WALKING, LEFT )}":
      new AnimatedSprite graphics, 'content/MyChar.bmp',
        0, 0, Game.kTileSize,
        Game.kTileSize, kSpriteFrameTime, 3

    "#{SpriteState.key( JUMPING, LEFT )}":
      new Sprite graphics, 'content/MyChar.bmp',
        kJumpFrame * Game.kTileSize, 0, Game.kTileSize,
        Game.kTileSize, kSpriteFrameTime, 3

    "#{SpriteState.key( FALLING, LEFT )}":
      new Sprite graphics, 'content/MyChar.bmp',
        kFallFrame * Game.kTileSize, 0, Game.kTileSize,
        Game.kTileSize, kSpriteFrameTime, 3

    "#{SpriteState.key( STANDING, RIGHT )}":
      new Sprite graphics, 'content/MyChar.bmp',
        0, Game.kTileSize, Game.kTileSize, Game.kTileSize

    "#{SpriteState.key( WALKING, RIGHT )}":
      new AnimatedSprite graphics, 'content/MyChar.bmp',
        0, Game.kTileSize, Game.kTileSize,
        Game.kTileSize, kSpriteFrameTime, 3

    "#{SpriteState.key( JUMPING, RIGHT )}":
      new Sprite graphics, 'content/MyChar.bmp',
        kJumpFrame * Game.kTileSize, Game.kTileSize,
        Game.kTileSize, Game.kTileSize, kSpriteFrameTime, 3

    "#{SpriteState.key( FALLING, RIGHT )}":
      new Sprite graphics, 'content/MyChar.bmp',
        kFallFrame * Game.kTileSize, Game.kTileSize,
        Game.kTileSize, Game.kTileSize, kSpriteFrameTime, 3

  update: (elapsed-time) ->

    # Propagate update to member instances
    @sprites[@get-sprite-state!].update elapsed-time
    @jump.update elapsed-time

    # Update physics
    @x += std.round @velocity-x * elapsed-time
    @y += std.round @velocity-y * elapsed-time

    @velocity-x += @acceleration-x * elapsed-time
    unless @jump.active
      @velocity-y = std.min @velocity-y + kGravity * elapsed-time, kMaxSpeedY

    # MOCK: Pretend floor
    if @y >= 320
      @y = 320
      @velocity-y = 0

    @on-ground = @y >= 320

    # Impart intention to Quote's position
    if @acceleration-x < 0
      @velocity-x = std.max(@velocity-x, -kMaxSpeedX);
    else if @acceleration-x > 0
      @velocity-x = std.min(@velocity-x, kMaxSpeedX);
    else if @on-ground
      @velocity-x *= kSlowdownFactor

  get-sprite-state: ->
    motion-type =
      if @on-ground
        if @acceleration-x is 0 then STANDING else WALKING
      else
        if @velocity-y < 0 then JUMPING else FALLING
    SpriteState.key motion-type, @horizontal-facing

  draw: (graphics) ->
    @sprites[@get-sprite-state!].draw graphics, @x, @y

  start-moving-left: ->
    @horizontal-facing = LEFT
    @acceleration-x = -kWalkingAcceleration

  start-moving-right: ->
    @horizontal-facing = RIGHT
    @acceleration-x = kWalkingAcceleration

  stop-moving: ->
    @acceleration-x = 0

  start-jump: ->
    if @on-ground
      @jump.reset!
      @velocity-y = -kJumpSpeed
    else if @velocity-y < 0
      @jump.reactivate!

  stop-jump: ->
    @jump.deactivate!

