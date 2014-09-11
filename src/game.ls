
# Game Class

# Require

require! \std
require! \SDL

Sprite = require \./sprite


# Reference constants

kFps = 60


# Internal state

running = yes
assets  = {}

graphics = null
sprite   = null


# Event loop
#
# Obviously JS has an event loop but I want to emulate RCS style where possible

event-loop = ->

  start-time = SDL.get-ticks!

  # Handle input
  while event = SDL.poll-event!
    switch event.type
    | SDL.KEYDOWN =>
      if event.key is SDL.KEY.ESCAPE
        running := no

    | SDL.KEYUP =>
      void

    | otherwise =>
      throw new Error message: "Unknown event type: " + event

  update!
  draw!

  # Queue next frame
  if running
    elapsed-time = SDL.get-ticks! - start-time
    SDL.delay 1000ms / kFps - elapsed-time, event-loop
  else
    std.log 'Game stopped.'


update = ->
  void

draw = ->

  # Instead of graphics.flip at the end, we have graphics.clear at the start
  graphics.clear!
  sprite.draw graphics, 320, 240


# Export

export start = ({ assets }) ->
  SDL.init(SDL.INIT_EVERYTHING);

  graphics := require \./graphics
  assets   := assets
  sprite   := new Sprite assets.MyChar, 0, 0, 32, 32

  event-loop!

