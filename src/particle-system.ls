
#
# Particle System
#

require! \std
require! \./units
require! \./readout


# Particle Tools
#
# Although Chris constructs his particle systems seperately and then passes
# them into the Tools, I thought it was probably easier just construct them
# here. The ParticleSystem constructor doesn't have any parameters anyway.

export class ParticleTools
  (@graphics) ->
    @entity-system = new ParticleSystem
    @front-system  = new ParticleSystem

  update: (elapsed-time) ->
    @entity-system.update elapsed-time
    @front-system.update elapsed-time


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

