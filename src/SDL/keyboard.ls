
# SDL Mock - Keyboard input

# Require

require! \std

queue = require \./event-queue


# Reference constants

[ KEYDOWN, KEYUP ] = std.enum

export KEYCODES =
  ESCAPE: 27


# Functions

monitor-keys = ->
  document.add-event-listener \keydown, ({ which }) ->
    queue.push-event { type: KEYDOWN, key: which }

  document.add-event-listener \keyup, ({ which }) ->
    queue.push-event { type: KEYUP, key: which }

export init = ->
  std.log "SDL::Keyboard - Monitoring key input"
  monitor-keys!


# Public constants

export KEYDOWN
export KEYUP

