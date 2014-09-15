
# SDL Mock for HTML Canvas
#
# The point of this module is to implement browser versions of the low-level
# functions relied on from SDL by RCS. Should mimic the same interfaces as
# much as possible. Functions include constructing the output window (canvas)
# and loading and blitting images.


# Require

require! \std


# SDL Submodules
delay       = require \./delay
timer       = require \./timer
screen      = require \./screen
keyboard    = require \./keyboard
event-queue = require \./event-queue

# SDL Classes
export Rect    = require \./rect
export Surface = require \./surface


# Reference constants

[ INIT_EVERYTHING, FULLSCREEN ] = std.enum


# Functions

export init = (mode) ->
  std.log "SDL::Init - with mode:", mode
  timer.init!
  keyboard.init!


# Export constants

export INIT_EVERYTHING
export FULLSCREEN
export keyboard.KEYDOWN
export keyboard.KEYUP
export KEY = keyboard.KEYCODES


# Facade to submodule functions

export delay.delay
export timer.get-ticks
export event-queue.poll-event
export screen.set-video-mode
export Surface.blit-surface
export Surface.set-color-key
export Surface.load-image

