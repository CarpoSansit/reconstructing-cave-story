
# Require

require! \std

{ kHalfTile, tile-to-px: tpx }:units = require \./units

{ Timer }                    = require \./timer
{ Rectangle }                = require \./rectangle
{ Kinematics }               = require \./kinematics
{ AnimatedSprite, Sprite }   = require \./sprite
{ MapCollidable, Side }      = require \./map-collidable
{ SimpleCollisionRectangle } = require \./collision-rectangle

{ FrictionAccelerator, kGravityAcc } = require \./accelerators


# Reference constants

[ HEALTH, MISSILES, EXPERIENCE ] = std.enum
[ SMALL, MEDIUM, LARGE ] = std.enum


# Pickup Abstract class

export class Pickup

  # Export namespaced constants
  @SMALL      = SMALL
  @MEDIUM     = MEDIUM
  @LARGE      = LARGE
  @HEALTH     = HEALTH
  @MISSILES   = MISSILES
  @EXPERIENCE = EXPERIENCE

  (@type, @value) ->
    @collison-rectangle = new Rectangle

  draw: (graphics) ->

  update: (elapsed-time) ->


# Experience Doodad - "Power Dorito"

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


# Flashing pickup - Missiles and Hearts work the same way

class FlashingPickup extends Pickup

  kLifetime      = 8000ms
  kStartPeriod   = 400ms
  kEndPeriod     = 75 * 3
  kFlickerPeriod = 75
  kDissipateTime = kLifetime - 25ms
  kFlickerTime   = kLifetime - 1000ms
  kFlashInterp   = (kEndPeriod - kStartPeriod) / kFlickerTime

  kSpriteName = \Npc/NpcSym

  kDissipatingSourceX = 1
  kDissipatingSourceY = 0

  (graphics, @center-x, @center-y, source-x, source-y, @rectangle, @value, @type) ->
    super @type, @value

    @x = @center-x - kHalfTile
    @y = @center-y - kHalfTile

    @timer = new Timer kLifetime, true

    @sprite = new Sprite graphics, kSpriteName,
      (tpx source-x), (tpx source-y), (tpx 1), (tpx 1)

    @flash-sprite = new Sprite graphics, kSpriteName,
      (tpx source-x + 1), (tpx source-y), (tpx 1), (tpx 1)

    @dissipating-sprite = new Sprite graphics, kSpriteName,
      (tpx kDissipatingSourceX), (tpx kDissipatingSourceY), (tpx 1), (tpx 1)

  collision-rectangle: ->
    new Rectangle @x + @rectangle.left, @y + @rectangle.top,
      @rectangle.w, @rectangle.h

  draw: (graphics) ->

    if @timer.current-time > kDissipateTime
      @dissipating-sprite.draw graphics, @x, @y

    else if @timer.current-time > kFlickerTime
      if (@timer.current-time `std.div` @flash-period % 3) is 0
        @sprite.draw graphics, @x, @y
      else if (@timer.current-time `std.div` @flash-period % 3) is 1
        @flash-sprite.draw graphics, @x, @y
      else
        void # One out of three times doesn't draw

    else  # During flicker time
      if (@timer.current-time `std.div` @flash-period % 2) is 0
        @sprite.draw graphics, @x, @y
      else
        @flash-sprite.draw graphics, @x, @y

  update: (elapsed-time) ->
    @flash-period =
      if @timer.current-time < kFlickerTime
        kFlashInterp * @timer.current-time + kStartPeriod
      else
        kFlickerPeriod

    return @timer.active!


export class HeartPickup extends FlashingPickup

  kRectangle   = new Rectangle 5, 8, 21, 19

  kSourceX     = 2
  kSourceY     = 5
  kHealthValue = 2

  (graphics, @center-x, @center-y) ->
    super graphics, @center-x, @center-y,
      kSourceX, kSourceY,
      kRectangle, kHealthValue, HEALTH

