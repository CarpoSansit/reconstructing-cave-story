
#
# Immobile Single-Loop Particle
#
# Particles consisting of an animated sprites that plays once and then dies,
# but is not required to move during it's lifetime.
#

require! \std

{ AnimatedSprite } = require \./sprite


# ImmobileSingleLoopParticle

export class ImmobileSingleLoopParticle

  (graphics, @x, @y, sprite-path, sprite-source, fps, frames) ->
    @sprite = new AnimatedSprite graphics,
      sprite-path, sprite-source, fps, [0 til frames]

  update: (elapsed-time) ->
    @sprite.update elapsed-time
    return @sprite.num-completed-loops is 0

  draw: (graphics) ->
    @sprite.draw graphics, @x, @y

