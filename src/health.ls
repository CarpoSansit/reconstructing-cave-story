
#
# Health
#

require! \std
require! \./units

{ div } = std
{ kHalfTile, px-to-tile, tile-to-px:tpx, px-to-game, tile-to-game } = units

{ Timer }        = require \./timer
{ SpriteSource } = require \./rectangle

{ Sprite, NumberSprite, VaryingWidthSprite } = require \./sprite


# Reference constants

kHealthBarX  = tile-to-game 1
kHealthBarY  = tile-to-game 2
kHealthFillX = tile-to-game 2.5
kHealthFillY = tile-to-game 2
kHealthNumX  = tile-to-game 1.5
kHealthNumY  = tile-to-game 2

kMaxFillPx   = tpx(2.5) - 1
kDamageDelay = 1500
kSpritePath  = \TextBox

# Sprite Sources

kBarSrcX    = 0
kBarSrcY    = 2.5
kFillSrcY   = 1.5
kDamageSrcY = 2

kBarSrcWidth  = 4
kBarSrcHeight = 0.5


# Health class

export class Health

  (graphics, @max-health = 6) ->
    @current-health = @max-health
    @damage = 0
    @damage-timer = new Timer kDamageDelay

    # Sprites
    @health-bar-sprite  = new Sprite graphics, kSpritePath,
      tpx(kBarSrcX), tpx(kBarSrcY), tpx(kBarSrcWidth), tpx(kBarSrcHeight)

    @health-fill-sprite = new VaryingWidthSprite graphics, kSpritePath,
      tpx(kBarSrcX), tpx(kFillSrcY), kMaxFillPx, tpx(kBarSrcHeight), kMaxFillPx

    @damage-fill-sprite = new VaryingWidthSprite graphics, kSpritePath,
      tpx(kBarSrcX), tpx(kDamageSrcY), kMaxFillPx, tpx(kBarSrcHeight), kMaxFillPx


  update: (elapsed-time) ->
    if @damage > 0 and @damage-timer.is-expired
      @current-health = std.max 0, @current-health - @damage
      @damage = 0

  draw: (graphics) ->
    @health-bar-sprite.draw graphics, kHealthBarX, kHealthBarY

    unless @current-health is 0
      if @damage
        @damage-fill-sprite.draw graphics, kHealthFillX, kHealthFillY
      @health-fill-sprite.draw graphics, kHealthFillX, kHealthFillY

    (new NumberSprite.HUDNumber graphics, @current-health, 2).draw graphics,
      kHealthNumX, kHealthNumY

  take-damage: (damage) ->
    return if @current-health is 0
    @damage-timer.reset!
    @health-fill-sprite.set-percentage-width (@current-health - damage) / @max-health
    @damage-fill-sprite.set-percentage-width @current-health / @max-health
    @damage = damage
    return @current-health - damage <= 0

