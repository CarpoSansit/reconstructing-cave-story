
#
# Damageable
#

require! \std

{ InterfaceError } = std


# Damageable pseudo-interface
#
# Although Livescript provides this mixin device with the `implements` keyword,
# it's not like a real interface because it provides no kind of enforcement.
# We can get a little way towards enforcement by adopting a convention for our
# codebase, of providing fallback properties which raise runtime errors about
# the lack of implementation.

export class Damageable
  center-x: 0  # Implement as a getter
  center-y: 0  # Implement as a getter
  get-damage-text: ->
    throw new InterfaceError "Damageable - `get-damage-text` method not implemented"

