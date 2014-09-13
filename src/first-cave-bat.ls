
#
# 'First Cave' Bat
#

require! \std
require! \./units

{ tile-to-px } = units

AnimatedSprite = require \./animated-sprite


# Reference constants

TILE_PX = tile-to-px 1
RIGHT   = "R"
LEFT    = "L"

kAngularVelocity = 120/1000  # degrees/second
kFlyFps          = 15
kNumFlyFrames    = 3


# Private Class: SpriteState - this will generalise later

class SpriteState
  (@facing = LEFT) ->
  key: -> @facing
  @key = (...args) -> String args.join '-'


# Bat Class

export class FirstCaveBat

  # FirstCaveBat (Game, Game)
  (graphics, @x, @y) ->
    std.log 'new Bat:', @x, @y
    @flight-angle = 0
    @angular-velocity = kAngularVelocity
    @horizontal-facing = RIGHT
    @sprites = @initialise-sprites graphics

  get-sprite-state: ->
    SpriteState.key @horizontal-facing

  initialise-sprite: (graphics, facing) ->
    facing-offset = if facing is RIGHT then 1 else 0
    new AnimatedSprite graphics, 'data/16x16/Npc/NpcCemet.bmp',
      tile-to-px(2), tile-to-px(2 + facing-offset),
      TILE_PX, TILE_PX, kFlyFps, kNumFlyFrames

  initialise-sprites: (graphics, sprite-map = {}) ->
    for facing in [ LEFT, RIGHT ]
      sprite-map[ SpriteState.key facing ] = @initialise-sprite graphics, facing
    return sprite-map

  update: (elapsed-time, player-x) ->
    @horizontal-facing = if player-x < @x then LEFT else RIGHT
    @flight-angle += @angular-velocity * elapsed-time
    @sprites[@get-sprite-state!].update elapsed-time

  draw: (graphics) ->
    y = @y + units.tile-to-game(5) / 2 * std.sin units.deg-to-rad @flight-angle
    @sprites[@get-sprite-state!].draw graphics, @x, y

