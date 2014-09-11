
# Require

require! \std


# Input class

module.exports = class Input
  ->
    @held-keys     = {}
    @pressed-keys  = {}
    @released-keys = {}

  begin-new-frame : ->
    @pressed-keys  = {}
    @released-keys = {}

  key-down-event : (event) ->
    @pressed-keys[event.key] = on
    @held-keys[event.key] = on

  key-up-event : (event) ->
    @released-keys[event.key] = on
    @held-keys[event.key] = off

  was-key-pressed  : (key) -> @pressed-keys[key]
  was-key-released : (key) -> @released-keys[key]
  is-key-held      : (key) -> @held-keys[key]

