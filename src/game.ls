
# Game Class

# Require

require! \std
require! \SDL

require! \./input
require! \./graphics

Player = require \./player
Map    = require \./map


# Reference constants

export kDebugMode = on
export kFps       = 60
export kTileSize  = 32


# Game singleton

std.log "Game - new Game"


# Internal state

running = yes
player  = null
map     = null
last-frame-time  = 0
any-keys-pressed = no


# Functions

event-loop = ->

  # Obviously JS has an event loop but I want to emulate RCS style where possible

  start-time = SDL.get-ticks!
  input.begin-new-frame!

  # Consume input events
  while event = SDL.poll-event!
    any-keys-pressed := yes
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

  # Walking
  if (input.is-key-held SDL.KEY.LEFT) and (input.is-key-held SDL.KEY.RIGHT)
    player.stop-moving!
  else if input.is-key-held SDL.KEY.LEFT
    player.start-moving-left!
  else if input.is-key-held SDL.KEY.RIGHT
    player.start-moving-right!
  else
    player.stop-moving!

  # Jumping
  if input.was-key-pressed SDL.KEY.Z
    player.start-jump!
  else if input.was-key-released SDL.KEY.Z
    player.stop-jump!

  # Looking
  if (input.is-key-held SDL.KEY.UP) and (input.is-key-held SDL.KEY.DOWN)
    player.look-horizontal!
  else if input.is-key-held SDL.KEY.UP
    player.look-up!
  else if input.is-key-held SDL.KEY.DOWN
    player.look-down!
  else
    player.look-horizontal!

  # Update and draw world
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
  player.update elapsed-time, map
  map.update elapsed-time

draw = ->
  graphics.clear!
  player.draw graphics, 320, 240
  map.draw graphics
  # no graphics.flip required

create-test-world = ->
  player := new Player 320, 240
  map    := Map.create-test-map graphics


export start = ->
  SDL.init(SDL.INIT_EVERYTHING);
  create-test-world!
  event-loop!

  # TESTING: Don't let the game loop run too long
  std.delay 5000, ->
    if !any-keys-pressed
      running := no
    else
      std.log "Game being interacted with. Don't shut down"

