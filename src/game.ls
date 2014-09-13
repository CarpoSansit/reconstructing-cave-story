
# Game
#
# Singleton. The contents of this file are equivalent to the contents of a
# class constructor. We simply delare all functions, and then make public the
# ones we want via `exports`

require! \std
require! \SDL

require! \./input
require! \./units
require! \./config
require! \./readout
require! \./graphics

Map    = require \./map

{ Player }        = require \./player
{ FirstCaveBat }  = require \./first-cave-bat
{ FixedBackdrop } = require \./backdrop
{ Rectangle }     = require \./rectangle


# Reference constants

{ kScreenWidth, kScreenHeight, kFps, kMaxFrameTime, kDebugMode } = config


# State

running  = yes
player   = null
bat      = null
map      = null
last-frame-time  = 0
any-keys-pressed = no


# Functions

# Game::event-loop
# Obviously JS has an event loop but I want to emulate RCS style where possible
event-loop = ->
  start-time = SDL.get-ticks!
  input.begin-new-frame!

  # Consume input events
  while event = SDL.poll-event!
    any-keys-pressed := yes
    readout.update \willstop, false
    switch event.type
    | SDL.KEYDOWN => input.key-down-event event
    | SDL.KEYUP   => input.key-up-event   event
    | otherwise   => throw new Error message: "Unknown event type: " + event


  # Interrogate key state

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

  # Measure time since last frame. If it's longer than the max skippable
  # frames, use that instead to stop the player falling out of the world
  # and causing errors.
  Δt = std.min SDL.get-ticks! - last-frame-time, kMaxFrameTime

  # Update and draw world
  update Δt
  draw!

  # Queue next frame
  if running
    last-frame-time := SDL.get-ticks!
    elapsed-time = last-frame-time - start-time

    # Update debug info
    readout.update \frametime, std.floor 1000 / Δt
    readout.update \drawtime, elapsed-time

    # This isn't even slightly similar to SDL_Delay but I've called it the
    # same and put it in SDL Mock for consistency with Chris' codebase.
    # Really, it ignores the delay time and calls requestAnimationFrame.
    SDL.delay 1000ms / kFps - elapsed-time, event-loop

  else
    std.log 'Game stopped.'

# Game::update
update = (elapsed-time) ->
  player.update elapsed-time, map
  bat.update elapsed-time, player.x
  readout.update \collided, bat.damage-collision!.collides-with player.damage-collision!

# Game::draw
draw = ->
  graphics.clear!
  map.draw-background graphics
  bat.draw graphics
  player.draw graphics
  map.draw graphics
  # No graphics.flip required

# Game::create-test-world
create-test-world = ->
  map    := Map.create-test-map graphics
  player := new Player graphics, units.tile-to-game(kScreenWidth/2), units.tile-to-game(kScreenHeight/2)
  bat    := new FirstCaveBat graphics, units.tile-to-game(7), units.tile-to-game(8)


# Game::start
export start = ->
  SDL.init(SDL.INIT_EVERYTHING);

  readout.add-reader \frametime, 'Frame time'
  readout.add-reader \drawtime, 'Draw time'
  readout.add-reader \willstop, 'Will stop', true
  readout.add-reader \collided, 'Collision?', false

  # Create game world
  create-test-world!

  # Begin game loop
  event-loop!

  player.start-moving-left!

  # TESTING: Don't let the game loop run too long
  std.delay 5000, ->
    if !any-keys-pressed
      void#running := no
    else
      std.log "Game being interacted with. Don't shut down"

