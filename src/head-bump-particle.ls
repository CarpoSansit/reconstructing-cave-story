
#
# 'Head Bump' Particle
#

require! \std
require! \./units

{ game-to-px: px } = units

{ Timer }       = require \./timer
{ Particle }    = require \./particle
{ Sprite }      = require \./sprite
{ PolarVector } = require \./polar
{ Rectangle }   = require \./rectangle


# Constants

kFlashPeriod  = 25
kLifeTime     = 700
kSpeed        = 0.12  # game units per ms


# HeadBumpParticle class

export class HeadBumpParticle extends Particle

  (graphics, @center-x, @center-y) ->
    @life-timer = new Timer kLifeTime, true

    @particle-a = new PolarVector 0, std.rand 0, std.tau
    @particle-b = new PolarVector 0, std.rand 0, std.tau

    @max-offset-a = std.floor std.rand 4, 20
    @max-offset-b = std.floor std.rand 4, 20

    @sprite = new Sprite graphics, \Caret, px(116), px(54), px(6), px(6)

  update: (elapsed-time) ->
    @particle-a.mag = std.min @max-offset-a, @particle-a.mag + elapsed-time * kSpeed
    @particle-b.mag = std.min @max-offset-b, @particle-b.mag + elapsed-time * kSpeed
    return @life-timer.active!

  draw: (graphics) ->
    if (@life-timer.current-time / kFlashPeriod) % 2 < 1
      @sprite.draw graphics, @center-x + @particle-a.x, @center-y + @particle-a.y
      @sprite.draw graphics, @center-x + @particle-b.x, @center-y + @particle-b.y

