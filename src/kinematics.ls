
#
# Kinematics
#
# Combined position and velocity management, for one axis at a time
#

require! \std
require! \./units


# Kinematics

export class Kinematics
  (@position, @velocity) ->
  delta: (elapsed-time) -> @velocity * elapsed-time

