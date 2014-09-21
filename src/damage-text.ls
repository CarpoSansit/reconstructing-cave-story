
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

  (graphics, @center-x, @center-y) ->
    @timer       = new Timer kVanishTime
    @damage      = 0
    @offset-y    = 0
    @should-rise = no

  set-position: (x, y) ->
    @center-x = x
    @center-y = y + @offset-y

  set-damage: (damage) ->
    @should-rise = @damage is 0
    if @should-rise then @offset-y = 0
    @damage += damage
    @timer.reset!

  update: (elapsed-time) ->
    if @timer.is-expired
      @damage = 0

    if @should-rise
      @offset-y = std.max units.tile-to-game(-1), @offset-y + kVelocity * elapsed-time

  draw: (graphics) ->
    if @timer.is-active and @damage > 0
      (new NumberSprite.DamageNumber graphics, @damage).draw-centered graphics,
        @center-x, @center-y

  expired:~ ->
    @timer.is-expired

