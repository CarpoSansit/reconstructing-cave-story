
#
# Wall Particle
#
# The effect that happens when the polar star projectiles smack into a wall.
#

require! \std
require! \./units

{ SpriteSource }   = require \./rectangle
{ ImmobileSingleLoopParticle } = require \./immobile-single-loop-particle


# Constants

kWallSrc = new SpriteSource 11, 0


# Star Particle

export class WallParticle extends ImmobileSingleLoopParticle
  (graphics, x, y) ->
    super graphics, x, y, \Caret, kWallSrc, 18, 4

