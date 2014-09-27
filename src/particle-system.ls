
#
# Particle System
#

require! \std
require! \./units


# Particle Tools

export class ParticleTools
  (@graphics, @system) ->


# Particle System

export class ParticleSystem

  ->
    @particles = []

  add-new-particle: ->
    @particles.push it

  update: (elapsed-time) ->
    @particles = std.filter (std.log . (.update elapsed-time)), @particles

  draw: (graphics) ->
    @particles.for-each (.draw graphics)

