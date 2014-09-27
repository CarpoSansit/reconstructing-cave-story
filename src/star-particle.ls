
#
# Star Particle
#
# The effect that happens when the polar star (and other things) are fied
# and then dissapate into the air.
#

require! \std
require! \./units

{ tile-to-px } = units

{ Particle }       = require \./particle
{ SpriteSource }   = require \./rectangle
{ AnimatedSprite } = require \./sprite

{ ImmobileSingleLoopParticle } = require \./immobile-single-loop-particle


# Constants

kStarSrc = new SpriteSource 0, 3


# Star Particle

export class StarParticle extends ImmobileSingleLoopParticle
  (graphics, x, y) ->
    super graphics, x, y, \Caret, kStarSrc, 18, 4

