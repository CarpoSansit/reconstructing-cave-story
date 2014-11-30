
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

Map = require \./map

{ tile-to-game } = units

{ Timer }              = require \./timer
{ Player }             = require \./player
{ Rectangle }          = require \./rectangle
{ FirstCaveBat }       = require \./first-cave-bat
{ FixedBackdrop }      = require \./backdrop
{ DamageTexts }        = require \./damage-texts
{ ParticleTools }      = require \./particle-system
{ StarParticle }       = require \./star-particle
{ DeathCloudParticle } = require \./death-cloud-particle


# Reference constants

{ kScreenWidth, kScreenHeight, kFps, kMaxFrameTime, kDebugMode } = config


# State

running = yes
player  = null
bat     = null
map     = null
ptools  = null

time-factor      = 1
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

  # Shooting
  if input.was-key-pressed SDL.KEY.X
    player.start-fire!
  else if input.was-key-released SDL.KEY.X
    player.stop-fire!

  # Looking
  if (input.is-key-held SDL.KEY.UP) and (input.is-key-held SDL.KEY.DOWN)
    player.look-horizontal!
  else if input.is-key-held SDL.KEY.UP
    player.look-up!
  else if input.is-key-held SDL.KEY.DOWN
    player.look-down!
  else
    player.look-horizontal!

  # Debug functions
  if input.was-key-pressed SDL.KEY.ONE   then time-factor := 1
  if input.was-key-pressed SDL.KEY.TWO   then time-factor := 2
  if input.was-key-pressed SDL.KEY.THREE then time-factor := 3
  if input.was-key-pressed SDL.KEY.FOUR  then time-factor := 4

  # Measure time since last frame. If it's longer than the max skippable
  # frames, use that instead to stop the player falling out of the world
  # and causing errors.
  Δt = std.min SDL.get-ticks! - last-frame-time, kMaxFrameTime

  # Update and draw world
  update Δt / time-factor
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
  Timer.update-all elapsed-time
  player.update elapsed-time, map

  # Bat died
  if bat and not bat?.update elapsed-time, player.x
    DeathCloudParticle.create-random-death-clouds ptools,
      bat.center-x, bat.center-y, 3
    bat := null

  # Bullet-to-enemy collisions
  for projectile in player.get-projectiles!
    if bat?.collision-rectangle!collides-with projectile.collision-rectangle!
      projectile.collide-with-enemy!
      bat.take-damage projectile.contact-damage

  # Enemy-to-player collisions
  if bat?.damage-collision!.collides-with player.damage-collision!
    player.take-damage bat.contact-damage

  # This goes last, because if collisions have caused damage, damagetexts
  # will suddenly exist which have not been updated, and will be drawn one
  # frame in their last known position
  DamageTexts.update elapsed-time
  ptools.update elapsed-time

# Game::draw
draw = ->
  graphics.clear!
  map.draw-background graphics
  bat?.draw graphics
  player.draw graphics
  ptools.entity-system.draw graphics
  map.draw graphics
  player.draw-hud graphics
  ptools.front-system.draw graphics
  DamageTexts.draw graphics

# Game::create-test-world
create-test-world = ->
  map    := Map.create-test-map graphics
  ptools := new ParticleTools graphics
  player := new Player graphics, units.tile-to-game(kScreenWidth/2), units.tile-to-game(10), ptools
  bat    := new FirstCaveBat graphics, units.tile-to-game(7), units.tile-to-game(8)

# Game::start
export start = ->
  SDL.init(SDL.INIT_EVERYTHING);

  readout.add-reader \frametime, 'Frame time'
  readout.add-reader \drawtime, 'Draw time'
  readout.add-reader \willstop, 'Will stop', true

  # Create game world
  create-test-world!

  # Begin game loop
  event-loop!

  # TESTING: Don't let the game loop run too long
  std.delay 5000, ->
    if !any-keys-pressed
      #void
      running := no
    else
      std.log "Game being interacted with. Don't shut down"

