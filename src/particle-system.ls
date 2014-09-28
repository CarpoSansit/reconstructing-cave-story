
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
    readout.add-reader \particles, \Particles, 0
    @entity-system = new ParticleSystem
    @front-system  = new ParticleSystem

  update: (elapsed-time) ->
    readout.update \particles, @entity-system.particles.length + @front-system.particles.length
    @entity-system.update elapsed-time
    @front-system.update elapsed-time


# Particle System

export class ParticleSystem
  ->
    @particles = []

  add-new-particle: ->
    @particles.push it

  update: (elapsed-time) ->
    @particles = std.filter (.update elapsed-time), @particles

  draw: (graphics) ->
    @particles.for-each (.draw graphics)

