
# Require

require! \std

{ Rectangle } = require \./rectangle


# Reference constants

[ HEALTH, MISSILES, EXPERIENCE ] = std.enum


# Pickup Abstract class

export class Pickup

  (@type, @value) ->
    @colliison-rectangle = new Rect

  draw: (graphics) ->

  update: (elapsed-time) ->


# Specific Pickup types







# Export public constants

# export HEALTH, MISSLES, EXPERIENCE

