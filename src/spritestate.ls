
#
# SpriteState Abstraction
#

require! \std
require! \./units


# For these, I'm using strings instead of numbers because it makes
# the debug readout much easier to understand. If this has performance
# implications later on I'll put it back.

[ STANDING, WALKING, JUMPING, FALLING, INTERACTING ] = <[ S W J F I ]>
[ LEFT, RIGHT ] = <[ L R ]>
[ UP, DOWN, HORIZONTAL ] = <[ U D H ]>


# SpriteState key constructor

export key = (...args) -> args.join '-'


# Export constants

export {
  STANDING,
  WALKING,
  JUMPING,
  FALLING,
  INTERACTING,
  LEFT,
  RIGHT,
  UP,
  DOWN,
  HORIZONTAL
}

