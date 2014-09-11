
# Require

require! \std

AnimatedSprite = require \./animated-sprite

# Get required info from Game

# Player class

module.exports = class Player

  (@x, @y) ->
    { kTileSize, assets } = require \./game

    @sprite = new AnimatedSprite assets.MyChar, 0, 0,
        kTileSize, kTileSize, 15, 3

  update: (elapsed-time) ->
    @sprite.update elapsed-time

  draw: (graphics) ->
    @sprite.draw graphics, @x, @y

  start-moving-left: ->
  start-moving-right: ->
  stop-moving: ->

