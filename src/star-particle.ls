
#
# Star Particle
#
# The effect that happens when the polar star (and other things) are fired
# and then dissapate into the air.
#

require! \std

{ SpriteSource }   = require \./rectangle
{ ImmobileSingleLoopParticle } = require \./immobile-single-loop-particle


# Constants

kStarSrc = new SpriteSource 0, 3


# Star Particle

export class StarParticle extends ImmobileSingleLoopParticle
  (graphics, x, y) ->
    super graphics, x, y, \Caret, kStarSrc, 18, 4

