
#
# DamageTexts
#
# Singleton
#
# Manages the global collection of DamageTexts
#

require! \std


# State

all-texts = []
damage-text-map = new WeakMap
reject = (std.flip std.reject) all-texts


# Export singleton

export DamageTexts =

  add-damageable: (damageable) ->
    std.log damageable
    text = damageable.get-damage-text!
    all-texts.push text
    damage-text-map.set text, damageable

  update: (elapsed-time) ->
    all-texts = reject (text) ->
      if not text.expired
        owner = damage-text-map.get text
        text.set-position owner.center-x, owner.center-y
      return text.update elapsed-time

  draw: (graphics) ->
    all-texts.map (.draw graphics)

