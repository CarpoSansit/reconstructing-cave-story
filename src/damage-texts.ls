
#
# DamageTexts
#
# Singleton
#
# Manages the global collection of DamageTexts
#

require! \std
require! \./readout


# State

all-texts = []
owners    = new WeakMap
reject    = std.flip std.reject


readout.add-reader \damageabletexts, 'DamageTexts', 0


# Export singleton

export DamageTexts =

  add-damageable: (damageable) ->
    text = damageable.get-damage-text!
    all-texts.push text
    owners.set text, damageable

  update: (elapsed-time) ->

    readout.update \damageabletexts, all-texts.length

    all-texts := reject all-texts, (text) ->
      std.log text, owners.get text
      if not text.expired
        owner = owners.get text

        text.set-position owner.center-x, owner.center-y
      return text.update elapsed-time

  draw: (graphics) ->
    for text in all-texts
      text.draw graphics #.map (.draw graphics)

