
#
# Particle
#

class InterfaceError extends Error
  (@message) ->
    @name = \InterfaceError


# Particle pseudo-interface
#
# Although Livescript provides this mixin device with the `implements` keyword,
# it's not like a real interface because it provides no kind of enforcement.
# We can get a little way towards enforcement by adopting a convention for our
# codebase, of providing fallback properties which raise runtime errors about
# the lack of implementation.

export class Particle

  update: (elapsed-time) ->
    throw new InterfaceError "Particle - `update` not implemented"

  draw: (graphics) ->
    throw new InterfaceError "Particle - `draw` not implemented"

