
#
# Floating Damage Text
#


require! \std
require! \./units

{ Timer } = require \./timer
{ NumberSprite } = require \./sprite

kVelocity   = -units.kHalfTile / 250
kVanishTime = 2000


# DamageText Class

export class DamageText

  (graphics, @x, @y) ->
    @timer = new Timer kVanishTime
    @damage   = 0
    @offset-y = 0

  set-damage: (@damage) ->
    @timer.reset!
    @offset-y = 0

  update: (elapsed-time) ->
    @offset-y = std.max units.tile-to-game(-1), @offset-y + kVelocity * elapsed-time

  draw: (graphics, x, y) ->
    if @timer.is-active!
      (new NumberSprite.DamageNumber graphics, @damage).draw-centered graphics, x, y + @offset-y

