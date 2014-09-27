
#
# Particle System
#

require! \std
require! \./units
require! \./readout


# Particle Tools

export class ParticleTools
  (@graphics, @system) ->


# Particle System

export class ParticleSystem
  ->
    readout.add-reader \particles, \Particles, 0
    @particles = []

  add-new-particle: ->
    @particles.push it

  update: (elapsed-time) ->
    readout.update \particles, @particles.length
    @particles = std.filter (.update elapsed-time), @particles

  draw: (graphics) ->
    @particles.for-each (.draw graphics)

