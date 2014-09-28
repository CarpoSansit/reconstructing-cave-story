
#
# Accelerator
#
# Standardised ways of changing an object's gravity, so that various different
# abstractions can delegate acceleration reliably.
#

require! \std

export kGravity       = 0.00078125
export kTerminalSpeed = 0.2998046875


# Accelerator abstract interface (not taken advantage of in LS version)

# class Accelerator
#   ->
#   update-velocity: (kinematics, elapsed-time) ->


# Zero

export class ZeroAccelerator
  ->
  update-velocity: ->


# Constant

export class ConstantAccelerator

  (@acc, @max-vel) ->

    # Compute function up-front instead of pushing if statement into body
    @update-velocity =
      if @acc < 0
        (kinematics, elapsed-time) ->
          kinematics.velocity = std.max kinematics.velocity +
            @acc * elapsed-time, @max-vel
      else
        (kinematics, elapsed-time) ->
          kinematics.velocity = std.min kinematics.velocity +
            @acc * elapsed-time, @max-vel


# Bidirectional

export class BidirectionalAccelerator

  (@acc, @max-vel) ->
    @positive = new ConstantAccelerator  @acc,  @max-vel
    @negative = new ConstantAccelerator -@acc, -@max-vel


# Friction

export class FrictionAccelerator

  (@friction) ->

  update-velocity: (kinematics, elapsed-time) ->
    kinematics.velocity =
      if kinematics.velocity > 0
        std.max 0, kinematics.velocity - @friction * elapsed-time
      else
        std.min 0, kinematics.velocity + @friction * elapsed-time


# Export static instances

export kZero       = new ZeroAccelerator
export kGravityAcc = new ConstantAccelerator kGravityAcc, kTerminalSpeed

