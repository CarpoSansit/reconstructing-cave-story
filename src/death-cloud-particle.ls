
#
# Death Cloud Particle
#
# The little puff of smoke that a creature emits when it dies
#

require! \./graphics
require! \./units

{ kHalfTile } = units

{ PolarVector }    = require \./polar
{ AnimatedSprite } = require \./sprite
{ SpriteSource }   = require \./rectangle


# Constants

kSrc = new SpriteSource 1, 0, 1, 1


# Death Cloud Particle

export class DeathCloudParticle

  (graphics, @center-x, @center-y, @speed, angle) ->
    @offset = new PolarVector 0, angle
    @sprite = new AnimatedSprite graphics, \Npc/NpcSym, kSrc, 18, [0 til 7]

  update: (elapsed-time) ->
    @sprite.update elapsed-time
    @offset.mag += elapsed-time * @speed
    return @sprite.num-completed-loops is 0

  draw: (graphics) ->
    @sprite.draw graphics,
      @center-x + @offset.x - kHalfTile,
      @center-y + @offset.y - kHalfTile

