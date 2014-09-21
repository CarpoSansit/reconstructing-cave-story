
#
# Damageable
#

require! \std

class InterfaceError extends Error
  (@message) ->
    @name = \InterfaceError


# Damageable pseudo-interface
#
# Although Livescript provides this mixin device with the `implements` keyword,
# it's not like a real interface because it provides no kind of enforcement.
# We can get a little way towards enforcement by adopting a convention for our
# codebase, of providing fallback properties which raise runtime errors about
# the lack of implementation.

export class Damageable
  center-x:~ ->
    throw new InterfaceError "Damageable - `center-x` getter not implemented"

  center-y:~ ->
    throw new InterfaceError "Damageable - `center-y` getter not implemented"

  get-damage-text: ->
    throw new InterfaceError "Damageable - `get-damage-text` method not implemented"

