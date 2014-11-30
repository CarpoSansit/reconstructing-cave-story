
# Require

require! \std

{ kHalfTile, tile-to-px: tpx }:units = require \./units

{ Timer }          = require \./timer
{ Rectangle }      = require \./rectangle
{ Kinematics }     = require \./kinematics
{ AnimatedSprite } = require \./sprite


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

export class PowerDorito extends Pickup

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

  update: (elapsed-time) ->
    @sprite.update!
    return @timer.is-active

  colliison-rectangle: ->
    return new Rectangle 0, 0, 0, 0


# Export public constants

# export HEALTH, MISSLES, EXPERIENCE

