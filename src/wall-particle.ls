
#
# Wall Particle
#
# The effect that happens when the polar star projectiles smack into a wall.
#

require! \std
require! \./units

{ tile-to-px: tpx } = require \./units
{ ImmobileSingleLoopParticle } = require \./immobile-single-loop-particle


# Star Particle

export class WallParticle extends ImmobileSingleLoopParticle
  (graphics, x, y) ->
    super graphics, x, y, \Caret, tpx(11), tpx(0), tpx(1), tpx(1), 18, 4

