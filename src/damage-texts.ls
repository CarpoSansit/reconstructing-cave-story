
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
owners    = new WeakMap
reject    = (std.flip std.reject) all-texts


# Export singleton

export DamageTexts =

  add-damageable: (damageable) ->
    text = damageable.get-damage-text!
    all-texts.push text
    owners.set text, damageable

  update: (elapsed-time) ->
    all-texts := reject (text) ->
      if not text.expired
        owner = owners.get text
        text.set-position owner.center-x, owner.center-y
      return text.update elapsed-time

  draw: (graphics) ->
    for text in all-texts
      text.draw graphics

