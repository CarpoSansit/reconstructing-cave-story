
#
# Polar Vector
#

require! \std


# Polar Vector

export class PolarVector
  (@mag, @angle) ->
  x:~ -> @mag * std.cos @angle
  y:~ -> @mag * std.sin @angle

