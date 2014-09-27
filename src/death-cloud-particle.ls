
#
# Death Cloud Particle
#
# The little puff of smoke that a creature emits when it dies
#


require! \std
require! \./units

{ kHalfTile, tile-to-px:tpx } = units

{ PolarVector }    = require \./polar
{ AnimatedSprite } = require \./sprite


# Constants

kBaseVelocity = 0.12


# Death Cloud Particle

export class DeathCloudParticle

  (graphics, @center-x, @center-y, @speed, angle) ->
    @offset = new PolarVector 0, angle
    @sprite = new AnimatedSprite graphics, \Npc/NpcSym,
      tpx(1), tpx(0), tpx(1), tpx(1),
      18, 7

  update: (elapsed-time) ->
    @sprite.update elapsed-time
    @offset.mag += elapsed-time * @speed
    return @sprite.num-completed-loops is 0

  draw: (graphics) ->
    @sprite.draw graphics,
      @center-x + @offset.x - kHalfTile,
      @center-y + @offset.y - kHalfTile

  @create-random-death-clouds = (ptools, center-x, center-y, num) ->
    for ix from 0 til num
      random-angle = std.rand 0, std.tau
      random-speed = kBaseVelocity * std.rand 0, 2
      ptools.entity-system.add-new-particle new DeathCloudParticle ptools.graphics,
        center-x, center-y, random-speed, random-angle

