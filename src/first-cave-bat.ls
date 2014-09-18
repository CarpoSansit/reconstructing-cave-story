
#
# 'First Cave' Bat
#

require! \std
require! \./units

{ tile-to-px, tile-to-game, kHalfTile, kTilePx } = units

{ Rectangle: Rect }        = require \./rectangle
{ Sprite, AnimatedSprite } = require \./sprite


# Reference constants

RIGHT     = "R"
LEFT      = "L"

kAngularVelocity = 120/1000  # degrees/second
kFlyFps          = 15
kNumFlyFrames    = 3
kContactDamage   = 1


# Private Class: SpriteState - this will generalise later

SpriteState = (...args) -> String args.join '-'


# Bat Class

export class FirstCaveBat

  # FirstCaveBat (Game, Game)
  (graphics, @x, @center-y) ->
    @y = @center-y
    @flight-angle = 0
    @angular-velocity = kAngularVelocity
    @horizontal-facing = RIGHT
    @sprites = @initialise-sprites graphics
    @contact-damage = kContactDamage

  get-sprite-state: ->
    SpriteState @horizontal-facing

  initialise-sprite: (graphics, facing) ->
    facing-offset = if facing is RIGHT then 1 else 0
    new AnimatedSprite graphics, 'Npc/NpcCemet',
      tile-to-px(2), tile-to-px(2 + facing-offset),
      kTilePx, kTilePx, kFlyFps, [ 0 til kNumFlyFrames ]

  initialise-sprites: (graphics, sprite-map = {}) ->
    for facing in [ LEFT, RIGHT ]
      sprite-map[ SpriteState facing ] = @initialise-sprite graphics, facing
    return sprite-map

  update: (elapsed-time, player-x) ->
    @horizontal-facing = if player-x < @x then LEFT else RIGHT
    @flight-angle += @angular-velocity * elapsed-time
    @y = @center-y + units.tile-to-game(5) / 2 * std.sin units.deg-to-rad @flight-angle
    @sprites[@get-sprite-state!].update elapsed-time

  draw: (graphics) ->
    #graphics.visualiseRect @damage-collision!, yes
    @sprites[@get-sprite-state!].draw graphics, @x, @y

  damage-collision: ->
    new Rect @x + kHalfTile, @y + kHalfTile, 1, 1

