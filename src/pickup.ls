
# Require

require! \std

{ kHalfTile, tile-to-px: tpx }:units = require \./units

{ Timer }                    = require \./timer
{ Rectangle }                = require \./rectangle
{ Kinematics }               = require \./kinematics
{ AnimatedSprite }           = require \./sprite
{ MapCollidable, Side }      = require \./map-collidable
{ SimpleCollisionRectangle } = require \./collision-rectangle

{ FrictionAccelerator, kGravityAcc } = require \./accelerators


# Reference constants

[ HEALTH, MISSILES, EXPERIENCE ] = std.enum
[ SMALL, MEDIUM, LARGE ] = std.enum


# Pickup Abstract class

export class Pickup

  @SMALL  = SMALL
  @MEDIUM = MEDIUM
  @LARGE  = LARGE

  (@type, @value) ->
    @collison-rectangle = new Rectangle

  draw: (graphics) ->

  update: (elapsed-time) ->


# Specific Pickup types

export class PowerDorito extends Pickup implements MapCollidable::

  kValues       = [ 1, 5, 20 ]
  kSpriteName   = \Npc/NpcSym
  kSourceX      = 0
  kSourceYs     = [ 1, 2, 3 ]
  kSourceWidth  = 1
  kSourceHeight = 1
  kFps          = 14
  kNumFrames    = 6
  kLifetime     = 8000ms
  kFlashtime    = 7000ms
  kFlashPeriod  = 50
  kBounceSpeed  = 0.225

  kFriction = new FrictionAccelerator 0.00002
  kCollisionRectangles = [
    new SimpleCollisionRectangle new Rectangle 8, 8, 16, 16
    new SimpleCollisionRectangle new Rectangle 4, 4, 24, 24
    new SimpleCollisionRectangle new Rectangle 0, 0, 32, 32
  ]

  (graphics, @center-x, @center-y, @size = SMALL) ->
    super EXPERIENCE, kValues[@size]

    @kinematics-x = new Kinematics @center-x - kHalfTile, 0.025 * std.rand -5, 5
    @kinematics-y = new Kinematics @center-y - kHalfTile, 0.025 * std.rand -5, 5

    @timer = new Timer kLifetime, yes
    @sprite = new AnimatedSprite graphics, kSpriteName,
      (tpx kSourceX), (tpx kSourceYs[@size]),
      (tpx kSourceWidth), (tpx kSourceHeight), kFps, kNumFrames

  draw: (graphics) ->
    if @timer.current-time < kFlashtime or (@timer.current-time `std.div` kFlashPeriod) % 2 is 0
      @sprite.draw graphics, @kinematics-x.position, @kinematics-y.position
    graphics.visualiseRect @collision-rectangle!

  update: (elapsed-time, map) ->
    @sprite.update!

    @update-y kCollisionRectangles[@size], kGravityAcc,
      @kinematics-x, @kinematics-y, elapsed-time, map

    @update-x kCollisionRectangles[@size], kFriction,
      @kinematics-x, @kinematics-y, elapsed-time, map

    return @timer.is-active

  collision-rectangle: ->
    box = kCollisionRectangles[@size].bounding-box
    new Rectangle @kinematics-x.position + box.left,
      @kinematics-y.position + box.top, box.w, box.h

  # Implements MapCollidable
  on-collision: (side, is-delta-direction) ->
    if side is Side.TOP
      @kinematics-y.velocity = 0
    else if side is Side.BOTTOM
      @kinematics-y.velocity = -kBounceSpeed
    else
      @kinematics-x.velocity *= -1

  on-delta: (side) ->


# Export public constants

# export HEALTH, MISSLES, EXPERIENCE

