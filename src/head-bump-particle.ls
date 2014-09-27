
#
# 'Head Bump' Particle
#

require! \std
require! \./units

{ game-to-px } = units

{ Timer }       = require \./timer
{ Sprite }      = require \./sprite
{ PolarVector } = require \./polar


# Constants

kSourceX      = 116
kSourceY      = 54
kSourceWidth  = 6
kSourceHeight = 6

kFlashPeriod  = 25
kLifeTime     = 1

kSpeed        = 0.06  # game units per ms


# HeadBumpParticle class

export class HeadBumpParticle

  (graphics, @center-x, @center-y) ->
    @life-timer = new Timer kLifeTime, true

    @particle-a = new PolarVector 0, std.rand 0, std.tau
    @particle-b = new PolarVector 0, std.rand 0, std.tau

    @max-offset-a = std.floor std.rand 4, 20
    @max-offset-b = std.floor std.rand 4, 20

    @sprite = new Sprite graphics, \Caret,
      game-to-px(kSourceX), game-to-px(kSourceY),
      game-to-px(kSourceWidth), game-to-px(kSourceHeight)

  update: (elapsed-time) ->
    @particle-a.mag = std.min @max-offset-a, @particle-a.mag + elapsed-time * kSpeed
    @particle-b.mag = std.min @max-offset-b, @particle-b.mag + elapsed-time * kSpeed
    return @life-timer.active

  draw: (graphics) ->
    if (@life-timer.current-time / kFlashPeriod) % 2 < 1
      @sprite.draw graphics, @center-x + @particle-a.x, @center-y + @particle-a.y
      @sprite.draw graphics, @center-x + @particle-b.x, @center-y + @particle-b.y

