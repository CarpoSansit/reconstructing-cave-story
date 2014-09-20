
# SDL Mock - Keyboard input

# Require

require! \std

queue = require \./event-queue


# Reference constants

[ KEYDOWN, KEYUP ] = std.enum

export KEYCODES =
  ESCAPE : 27
  LEFT   : 37
  UP     : 38
  RIGHT  : 39
  DOWN   : 40
  ONE    : 49
  TWO    : 50
  THREE  : 51
  FOUR   : 52
  FIVE   : 53
  SIX    : 54
  SEVEN  : 55
  EIGHT  : 56
  NINE   : 57
  A      : 65
  Q      : 81
  S      : 83
  W      : 87
  X      : 88
  Z      : 90

# Functions

monitor-keys = ->
  document.add-event-listener \keydown, ({ which }:event) ->
    #std.info which
    queue.push-event { type: KEYDOWN, key: which }
    if which is KEYCODES.UP or
       which is KEYCODES.DOWN or
       which is KEYCODES.LEFT or
       which is KEYCODES.RIGHT
      event.prevent-default!

  document.add-event-listener \keyup, ({ which }:event) ->
    queue.push-event { type: KEYUP, key: which }
    event.prevent-default!

export init = ->
  std.log "SDL::Keyboard - Monitoring key input"
  monitor-keys!


# Public constants

export KEYDOWN
export KEYUP

