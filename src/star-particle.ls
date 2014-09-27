
#
# Star Particle
#
# The effect that happens when the polar star (and other things) are fired
# and then dissapate into the air.
#

require! \std

{ tile-to-px: tpx } = require \./units
{ ImmobileSingleLoopParticle } = require \./immobile-single-loop-particle



# Star Particle

export class StarParticle extends ImmobileSingleLoopParticle
  (graphics, x, y) ->
    super graphics, x, y, \Caret, tpx(0), tpx(3), tpx(1), tpx(1), 18, 4

