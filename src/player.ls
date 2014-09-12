
# Require

require! \std
require! \./graphics

Game           = require \./game
Map            = require \./map
Rect           = require \./rectangle
Sprite         = require \./sprite
AnimatedSprite = require \./animated-sprite


# Animation constants
kSpriteFrameTime     = 15
kCharacterFrame      = 20
kWalkFrame           = 0
kStandFrame          = 0
kJumpFrame           = 1
kFallFrame           = 2
kUpFrameOffset       = 3
kDownFrame           = 6
kBackFrame           = 7

# Physics constants
kSlowdownFactor      = 0.8
kWalkingAcceleration = 0.0012
kMaxSpeedX           = 0.325
kMaxSpeedY           = 0.325
kGravity             = 0.0012
kJumpSpeed           = 0.325
kJumpTime            = 275

# Collision spaces
kCollisionX = new Rect 6, 10, 20, 12
kCollisionY = new Rect 10, 2, 12, 30

# Enumerated constants
[ STANDING, WALKING, JUMPING, FALLING ] = std.enum
[ LEFT, RIGHT ] = std.enum
[ UP, DOWN, HORIZONTAL ] = std.enum


# Private class: SpriteState

class SpriteState
  ( @motion-type       = STANDING,
    @horizontal-facing = LEFT,
    @vertical-facing   = HORIZONTAL ) ->

  key: ->
    "#{@motion-type}-#{@horizontal-facing}-#{@vertical-facing}"

  @key = (...args) ->
    args.join '-'


# Private class: Jump

class Jump
  ->
    @time-remaining = 0ms
    @active         = no

  update: (elapsed-time) ->
    if @active
      @time-remaining -= elapsed-time
      if @time-remaining <= 0
        @active = no

  reset: ->
    @time-remaining = kJumpTime
    @reactivate!

  reactivate: ->
    @active = @time-remaining > 0

  deactivate: ->
    @active = no


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

    # Helper instances
    @jump = new Jump

    # Sprite management
    @sprite-state = new SpriteState STANDING, LEFT
    @sprites = @initialise-sprites!

  initialise-sprite: (motion, hfacing, vfacing) ->
    source-x =
      switch motion
      | WALKING  => kWalkFrame  * Game.kTileSize
      | STANDING => kStandFrame * Game.kTileSize
      | JUMPING  => kJumpFrame  * Game.kTileSize
      | FALLING  => kFallFrame  * Game.kTileSize
      | _ => void

    source-x += if vfacing is UP then kUpFrameOffset * Game.kTileSize else 0

    source-y =
      if hfacing is LEFT
        kCharacterFrame * Game.kTileSize
      else
        (kCharacterFrame + 1) * Game.kTileSize

    if motion is WALKING
      new AnimatedSprite graphics, 'content/MyChar.bmp',
        source-x, source-y, Game.kTileSize, Game.kTileSize,
        kSpriteFrameTime, 3
    else
      if vfacing is DOWN
        source-x =
          if motion is STANDING
            kBackFrame * Game.kTileSize
          else
            kDownFrame * Game.kTileSize

      new Sprite graphics, 'content/MyChar.bmp',
        source-x, source-y, Game.kTileSize, Game.kTileSize

  initialise-sprites: (sprite-map = {}) ->
    for motion in [ STANDING, WALKING, JUMPING, FALLING ]
      for hfacing in [ LEFT, RIGHT ]
        for vfacing in [ UP, DOWN, HORIZONTAL ]
          sprite-map[ SpriteState.key motion, hfacing, vfacing ] =
            @initialise-sprite motion, hfacing, vfacing
    return sprite-map

  update: (elapsed-time, map) ->

    # Propagate update to member instances
    @sprites[@get-sprite-state!].update elapsed-time
    @jump.update elapsed-time

    # Update physics
    @update-x elapsed-time, map
    @update-y elapsed-time, map

  update-x: (elapsed-time, map) ->
    @velocity-x += @acceleration-x * elapsed-time

    if @acceleration-x < 0
      @velocity-x = std.max(@velocity-x, -kMaxSpeedX);
    else if @acceleration-x > 0
      @velocity-x = std.min(@velocity-x, kMaxSpeedX);
    else if @on-ground
      @velocity-x *= kSlowdownFactor

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
    unless @jump.active
      @velocity-y = std.min @velocity-y + kGravity * elapsed-time, kMaxSpeedY

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


  get-sprite-state: ->
    motion-type =
      if @on-ground
        if @acceleration-x is 0 then STANDING else WALKING
      else
        if @velocity-y < 0 then JUMPING else FALLING
    SpriteState.key motion-type, @horizontal-facing, @vertical-facing

  draw: (graphics) ->
    @sprites[@get-sprite-state!].draw graphics, @x, @y


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


  # Walking methods

  start-moving-left: ->
    @horizontal-facing = LEFT
    @acceleration-x = -kWalkingAcceleration

  start-moving-right: ->
    @horizontal-facing = RIGHT
    @acceleration-x = kWalkingAcceleration

  stop-moving: ->
    @acceleration-x = 0


  # Jumping methods

  start-jump: ->
    if @on-ground
      @jump.reset!
      @velocity-y = -kJumpSpeed
    else if @velocity-y < 0
      @jump.reactivate!

  stop-jump: ->
    @jump.deactivate!


  # Looking methods

  look-up: ->
    @vertical-facing = UP

  look-down: ->
    @vertical-facing = DOWN

  look-horizontal: ->
    @vertical-facing = HORIZONTAL


