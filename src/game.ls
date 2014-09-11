
# Game Class

# Require

require! \std
require! \SDL

require! \./input
require! \./graphics

Player = require \./player


# Reference constants

export kFps      = 60
export kTileSize = 32


# Internal state

running = yes
player  = null
last-frame-time = 0


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


  #
  # Interrogate key state
  #

  # Escape to quit
  if input.was-key-pressed SDL.KEY.ESCAPE
    running := no

  # Arrow keys control the player
  if (input.is-key-held SDL.KEY.LEFT) and (input.is-key-held SDL.KEY.RIGHT)
    player.stop-moving!
  else if input.is-key-held SDL.KEY.LEFT
    player.start-moving-left!
  else if input.is-key-held SDL.KEY.RIGHT
    player.start-moving-right!
  else
    player.stop-moving!


  # Updates and drawing
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
  player.update elapsed-time

draw = ->
  graphics.clear!
  player.draw graphics, 320, 240
  # no graphics.flip required


# Export

export start = ({ assets }) ->
  SDL.init(SDL.INIT_EVERYTHING);

  # Make asset library available
  export assets := assets

  # Create game world
  player := new Player 320, 240

  # Begin game loop
  event-loop!

  # TESTING: Don't let the game loop run long
  std.delay 10000, ->
    running := no

