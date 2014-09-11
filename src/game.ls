
# Game Class

# Require

require! \std
require! \SDL

Input          = require \./input
Sprite         = require \./sprite
AnimatedSprite = require \./animated-sprite


# Reference constants

export kFps = 60
export kTileSize = 32


# Internal state

running = yes
assets  = {}
last-frame-time = 0

input    = null
graphics = null
sprite   = null


# Event loop
#
# Obviously JS has an event loop but I want to emulate RCS style where possible

event-loop = ->

  start-time = SDL.get-ticks!
  input.begin-new-frame!

  # Consume input events
  while event = SDL.poll-event!
    switch event.type
    | SDL.KEYDOWN => input.key-down-event event
    | SDL.KEYUP   => input.key-up-event   event
    | otherwise   => throw new Error message: "Unknown event type: " + event

  # Interrogate key state
  if input.was-key-pressed SDL.KEY.ESCAPE
    running := no

  update SDL.get-ticks! - last-frame-time
  draw!

  # Queue next frame
  if running
    last-frame-time := SDL.get-ticks!
    elapsed-time = last-frame-time - start-time
    SDL.delay 1000ms / kFps - elapsed-time, event-loop
  else
    std.log 'Game stopped.'


update = (elapsed-time) ->
  sprite.update elapsed-time

draw = ->
  # Instead of graphics.flip at the end, we have graphics.clear at the start
  graphics.clear!
  sprite.draw graphics, 320, 240


# Export

export start = ({ assets }) ->
  SDL.init(SDL.INIT_EVERYTHING);

  graphics := require \./graphics
  input    := new Input
  assets   := assets
  sprite   := new AnimatedSprite assets.MyChar, 0, 0, kTileSize, kTileSize, 15, 3

  event-loop!

  # TESTING: Don't let the game loop run long
  std.delay 3000, ->
    running := no

