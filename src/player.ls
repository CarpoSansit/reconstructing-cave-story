
# Require

require! \std
require! \./graphics
require! \./readout

Game           = require \./game
Map            = require \./map
Rect           = require \./rectangle
Sprite         = require \./sprite
AnimatedSprite = require \./animated-sprite


# Animation constants
kSpriteFrameTime     = 15
kCharacterFrame      = 0
kWalkFrame           = 0
kStandFrame          = 0
kJumpFrame           = 1
kFallFrame           = 2
kUpFrameOffset       = 3
kDownFrame           = 6
kBackFrame           = 7

# Physics constants
kFriction            = 0.00049804687
kGravity             = 0.00078125
kWalkingAcceleration = 0.00083007812
kAirAcceleration     = 0.0003125
kMaxSpeedX           = 0.15859375
kMaxSpeedY           = 0.2998046875
kJumpSpeed           = 0.25
kJumpGravity         = 0.0003125

# Collision spaces
# Because we don't have macros, I created this 5th multiplier argument instead
# TODO: Put the tilesize somewhere outside of Game so everyone can reference it
kCollisionX = new Rect 6, 10, 20, 12, 16 / 32
kCollisionY = new Rect 10, 2, 12, 30, 16 / 32

# Enumerated constants
[ STANDING, WALKING, JUMPING, FALLING, INTERACTING ] = <[ S W J F I ]>
[ LEFT, RIGHT ] = <[ L R ]>
[ UP, DOWN, HORIZONTAL ] = <[ U D H ]>


# Private class: SpriteState

class SpriteState
  ( @motion-type       = STANDING,
    @horizontal-facing = LEFT,
    @vertical-facing   = HORIZONTAL ) ->

  key: ->
    "#{@motion-type}-#{@horizontal-facing}-#{@vertical-facing}"

  @key = (...args) ->
    args.join '-'


# Player class
module.exports = class Player

  (@x, @y) ->

    # Player state (excluding x and y)
    @velocity-y        = 0
    @velocity-x        = 0
    @acceleration-x    = 0
    @horizontal-facing = LEFT
    @vertical-facing   = HORIZONTAL
    @on-ground         = no
    @jump-active       = no
    @interacting       = no

    # Sprite management
    @sprites = @initialise-sprites!

    # Debug
    if Game.kDebugMode
      readout.add-reader \spritestate, 'SpriteState'

  initialise-sprite: (motion, hfacing, vfacing) ->
    source-x =
      switch motion
      | WALKING     => kWalkFrame  * Game.kTileSize
      | STANDING    => kStandFrame * Game.kTileSize
      | JUMPING     => kJumpFrame  * Game.kTileSize
      | FALLING     => kFallFrame  * Game.kTileSize
      | INTERACTING => kBackFrame  * Game.kTileSize
      | _ => void

    source-x += if vfacing is UP then kUpFrameOffset * Game.kTileSize else 0

    source-y =
      if hfacing is LEFT
        kCharacterFrame * Game.kTileSize
      else
        (kCharacterFrame + 1) * Game.kTileSize

    if motion is WALKING
      new AnimatedSprite graphics, 'data/16x16/MyChar.bmp',
        source-x, source-y, Game.kTileSize, Game.kTileSize,
        kSpriteFrameTime, 3
    else
      if vfacing is DOWN and (motion is JUMPING or motion is FALLING)
        source-x = kDownFrame * Game.kTileSize

      new Sprite graphics, 'data/16x16/MyChar.bmp',
        source-x, source-y, Game.kTileSize, Game.kTileSize

  initialise-sprites: (sprite-map = {}) ->
    for motion in [ STANDING, WALKING, JUMPING, FALLING, INTERACTING ]
      for hfacing in [ LEFT, RIGHT ]
        for vfacing in [ UP, DOWN, HORIZONTAL ]
          sprite-map[ SpriteState.key motion, hfacing, vfacing ] =
            @initialise-sprite motion, hfacing, vfacing
    return sprite-map

  update: (elapsed-time, map) ->
    @sprites[@get-sprite-state!].update elapsed-time
    @update-x elapsed-time, map
    @update-y elapsed-time, map

  update-x: (elapsed-time, map) ->
    acc-x = if @on-ground then kWalkingAcceleration else kAirAcceleration
    @velocity-x += @acceleration-x * acc-x * elapsed-time

    if @acceleration-x < 0
      @velocity-x = std.max(@velocity-x, -kMaxSpeedX);
    else if @acceleration-x > 0
      @velocity-x = std.min(@velocity-x, kMaxSpeedX);
    else if @on-ground
      @velocity-x =
        if @velocity-x > 0
          std.max 0, @velocity-x - kFriction * elapsed-time
        else
          std.min 0, @velocity-x + kFriction * elapsed-time

    Δx = std.round @velocity-x * elapsed-time

    if Δx > 0
      @on-wall-collision map, (@right-collision Δx), (tile) ->
        if tile
          @x = tile.col * Game.kTileSize - kCollisionX.right
          @velocity-x = 0
        else
          @x += Δx

      @on-wall-collision map, (@left-collision 0), (tile) ->
        if tile
          @x = tile.col * Game.kTileSize + kCollisionX.right

    else
      @on-wall-collision map, (@left-collision Δx), (tile) ->
        if tile
          @x = tile.col * Game.kTileSize + kCollisionX.right
          @velocity-x = 0
        else
          @x += Δx

      @on-wall-collision map, (@right-collision 0), (tile) ->
        if tile
          @x = tile.col * Game.kTileSize - kCollisionX.right


  update-y: (elapsed-time, map) ->
    gravity = if @jump-active and @velocity-y < 0 then kJumpGravity else kGravity
    @velocity-y = std.min @velocity-y + gravity * elapsed-time, kMaxSpeedY

    Δy = std.round @velocity-y * elapsed-time

    # Falling
    if Δy > 0
      @on-wall-collision map, (@bottom-collision Δy), (tile) ->
        if tile
          @y = tile.row * Game.kTileSize - kCollisionY.bottom
          @velocity-y = 0
          @on-ground = yes
        else
          @y += Δy
          @on-ground = no

      @on-wall-collision map, (@top-collision 0), (tile) ->
        if tile
          @y = tile.row * Game.kTileSize + kCollisionY.h

    # Jumping
    else
      @on-wall-collision map, (@top-collision Δy), (tile) ->
        if tile
          @y = tile.row * Game.kTileSize + kCollisionY.h
          @velocity-y = 0
        else
          @y += Δy
          @on-ground = no

      @on-wall-collision map, (@bottom-collision 0), (tile) ->
        if tile
          @y = tile.row * Game.kTileSize - kCollisionY.bottom
          @on-ground = yes


  draw: (graphics) ->
    @sprites[@get-sprite-state!].draw graphics, @x, @y

  get-sprite-state: ->
    motion-type =
      if @interacting
        INTERACTING
      else if @on-ground
        if @acceleration-x is 0 then STANDING else WALKING
      else
        if @velocity-y < 0 then JUMPING else FALLING
    key = SpriteState.key motion-type, @horizontal-facing, @vertical-facing
    readout.update \spritestate, key
    return key


  # Collision spaces

  left-collision: (Δ) -> # Δ <= 0
    new Rect @x + kCollisionX.left + Δ, @y + kCollisionX.top,
      kCollisionX.w/2 - Δ, kCollisionX.h

  right-collision: (Δ) -> # Δ >= 0
    new Rect @x + kCollisionX.left + kCollisionX.w/2,
      @y + kCollisionX.top,
      kCollisionX.w/2 + Δ, kCollisionX.h

  top-collision: (Δ) ->
    new Rect @x + kCollisionY.left, @y + kCollisionY.top + Δ,
      kCollisionY.w, kCollisionY.h/2 - Δ

  bottom-collision: (Δ) ->
    new Rect @x + kCollisionY.left,
      @y + kCollisionY.top + kCollisionY.h/2 + Δ
      kCollisionY.w, kCollisionY.h/2 + Δ

  on-wall-collision: (map, rect, λ) ->
    for tile in map.get-colliding-tiles rect
      if tile.type is Map.WALL_TILE
        return λ.call this, tile
    λ.call this


  # Button handlers

  start-moving-left: ->
    @horizontal-facing = LEFT
    @acceleration-x = -1
    @interacting = no

  start-moving-right: ->
    @horizontal-facing = RIGHT
    @acceleration-x = 1
    @interacting = no

  stop-moving: ->
    @acceleration-x = 0

  start-jump: ->
    @jump-active = yes
    @interacting = no
    @velocity-y = -kJumpSpeed if @on-ground

  stop-jump: ->
    @jump-active = no

  look-up: ->
    @vertical-facing = UP
    @interacting = no

  look-down: ->
    return if @vertical-facing is DOWN
    @vertical-facing = DOWN
    @interacting = @on-ground

  look-horizontal: ->
    @vertical-facing = HORIZONTAL

