
# Require

require! \std
require! \./graphics

Game = require \./game
AnimatedSprite = require \./animated-sprite


# Animation constants
kSpriteFrameTime     = 15

# Physics constants
kSlowdownFactor      = 0.8
kWalkingAcceleration = 0.0012
kMaxSpeedX           = 0.325

# Player class

module.exports = class Player

  (@x, @y) ->

    @velocity-x     = 0
    @acceleration-x = 0

    @sprite = new AnimatedSprite graphics, 'content/MyChar.bmp',
      0, 0, Game.kTileSize, Game.kTileSize, kSpriteFrameTime, 3

  update: (elapsed-time) ->
    @sprite.update elapsed-time
    @x += std.round @velocity-x * elapsed-time
    @velocity-x += @acceleration-x * elapsed-time

    if @acceleration-x < 0
      @velocity-x = std.max(@velocity-x, -kMaxSpeedX);
    else if @acceleration-x > 0
      @velocity-x = std.min(@velocity-x, kMaxSpeedX);
    else
      @velocity-x *= kSlowdownFactor


  draw: (graphics) ->
    @sprite.draw graphics, @x, @y

  start-moving-left: ->
    @acceleration-x = -kWalkingAcceleration

  start-moving-right: ->
    @acceleration-x = kWalkingAcceleration

  stop-moving: ->
    @acceleration-x = 0

