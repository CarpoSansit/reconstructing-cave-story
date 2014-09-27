
#
# 'First Cave' Bat
#

require! \std
require! \./units
require! \./config

{ tile-to-px: tpx, tile-to-game, kHalfTile } = units

{ Damageable }             = require \./damageable
{ DamageText }             = require \./damage-text
{ DamageTexts }            = require \./damage-texts
{ Sprite, AnimatedSprite } = require \./sprite

{ Rectangle: Rect } = require \./rectangle


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

export class FirstCaveBat extends Damageable

  # FirstCaveBat (Game, Game)
  (graphics, @x, @flight-center-y) ->
    @y = @flight-center-y
    @flight-angle = 0
    @alive = yes
    @angular-velocity = kAngularVelocity
    @sprites = @initialise-sprites graphics
    @damage-text = new DamageText graphics
    @contact-damage = kContactDamage
    DamageTexts.add-damageable this

  spritestate:~ ->
    SpriteState @horizontal-facing

  initialise-sprite: (graphics, facing) ->
    facing-offset = if facing is RIGHT then 1 else 0
    new AnimatedSprite graphics, 'Npc/NpcCemet',
      tpx(2), tpx(2 + facing-offset), tpx(1), tpx(1), kFlyFps, kNumFlyFrames

  initialise-sprites: (graphics, sprite-map = {}) ->
    for facing in [ LEFT, RIGHT ]
      sprite-map[ SpriteState facing ] = @initialise-sprite graphics, facing
    return sprite-map

  update: (elapsed-time, player-x) ->
    @horizontal-facing = if player-x < @x then LEFT else RIGHT
    @flight-angle += @angular-velocity * elapsed-time
    @y = @flight-center-y + units.tile-to-game(5) / 2 * std.sin units.deg-to-rad @flight-angle
    @sprites[@spritestate].update elapsed-time
    return @alive

  draw: (graphics) ->
    if config.show-collisions
      graphics.visualiseRect @collision-rectangle!
    @sprites[@spritestate].draw graphics, @x, @y

  damage-collision: ->
    new Rect @center-x, @center-y, 1, 1

  collision-rectangle: ->
    new Rect @x, @y, tile-to-game(1), tile-to-game(1)

  take-damage: (damage) ->
    @damage-text.set-damage damage
    @alive = no

  # Damageable
  center-x:~ -> @x + kHalfTile
  center-y:~ -> @y + kHalfTile
  get-damage-text: -> @damage-text

