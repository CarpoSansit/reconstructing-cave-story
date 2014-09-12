
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

# Enumerated constants
[ STANDING, WALKING ] = std.enum
[ LEFT, RIGHT ] = std.enum


# Private class: SpriteState

class SpriteState
  (@motion-type = STANDING, @horizontal-facing = LEFT) ->
  key: -> "#{@motion-type}-#{@horizontal-facing}"
  @key = (...args) -> args.join '-'


# Player class
module.exports = class Player

  (@x, @y) ->

    # Player state (excluding x and y)
    @velocity-x        = 0
    @acceleration-x    = 0
    @horizontal-facing = LEFT

    # Sprite management
    @sprite-state = new SpriteState STANDING, LEFT
    @sprites = @initialise-sprites!

  initialise-sprites: (sprite-map = {}) ->

    "#{SpriteState.key( STANDING, LEFT )}":
      new Sprite graphics, 'content/MyChar.bmp',
        0, 0, Game.kTileSize, Game.kTileSize

    "#{SpriteState.key( WALKING, LEFT )}":
      new AnimatedSprite graphics, 'content/MyChar.bmp',
        0, 0, Game.kTileSize, Game.kTileSize, kSpriteFrameTime, 3

    "#{SpriteState.key( STANDING, RIGHT )}":
      new Sprite graphics, 'content/MyChar.bmp',
        0, Game.kTileSize, Game.kTileSize, Game.kTileSize

    "#{SpriteState.key( WALKING, RIGHT )}":
      new AnimatedSprite graphics, 'content/MyChar.bmp',
        0, Game.kTileSize, Game.kTileSize, Game.kTileSize, kSpriteFrameTime, 3

  update: (elapsed-time) ->
    @sprites[@get-sprite-state!].update elapsed-time
    @x += std.round @velocity-x * elapsed-time
    @velocity-x += @acceleration-x * elapsed-time

    if @acceleration-x < 0
      @velocity-x = std.max(@velocity-x, -kMaxSpeedX);
    else if @acceleration-x > 0
      @velocity-x = std.min(@velocity-x, kMaxSpeedX);
    else
      @velocity-x *= kSlowdownFactor

  get-sprite-state: ->
    motion-type = if @acceleration-x is 0 then STANDING else WALKING
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

