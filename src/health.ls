
#
# Health
#

require! \std
require! \./units

{ div } = std
{ kHalfTile, tile-to-px, px-to-game, tile-to-game } = units

{ Sprite, NumberSprite, VaryingWidthSprite } = require \./sprite


# Reference constants

kHealthBarX  = tile-to-game 1
kHealthBarY  = tile-to-game 2
kHealthFillX = tile-to-game 2.5
kHealthFillY = tile-to-game 2
kHealthNumX  = tile-to-game 1.5
kHealthNumY  = tile-to-game 2

kMaxFillPx  = tile-to-px(2.5) - 1

kDamageTime = 1500


# Health class

export class Health

  # Health (Graphics)
  (graphics, @max-health = 6) ->

    @current-health = @max-health
    @damage = 0

    # Timers
    @damage-time = 0

    # Sprites
    @health-bar-sprite = new Sprite graphics, 'data/16x16/TextBox.bmp',
      0, tile-to-px(2.5), tile-to-px(4), tile-to-px(0.5)

    @health-fill-sprite = new VaryingWidthSprite graphics, 'data/16x16/TextBox.bmp',
      0, tile-to-px(1.5), kMaxFillPx, tile-to-px(0.5)

    @damage-fill-sprite = new VaryingWidthSprite graphics, 'data/16x16/TextBox.bmp',
      0, tile-to-px(2.0), kMaxFillPx, tile-to-px(0.5)

  # Health::take-damage (HP) -> Bool
  take-damage: (damage) ->
    return if @current-health is 0
    @damage = damage
    @damage-time = 0
    @health-fill-sprite.set-width @fill-offset @current-health - damage
    @damage-fill-sprite.set-width @fill-offset damage
    return @current-health - damage <= 0

  # Health::update (ms)
  update: (elapsed-time) ->
    if @damage
      @damage-time += elapsed-time
      if @damage-time >= kDamageTime
        @current-health = std.max 0, @current-health - @damage
        @damage = 0

  # Health::fill-offset (HP)
  fill-offset: (health) ->
    kMaxFillPx * (health / @max-health)

  # Health::draw (Graphics)
  draw: (graphics) ->
    @health-bar-sprite.draw  graphics, kHealthBarX,  kHealthBarY

    unless @current-health is 0
      @health-fill-sprite.draw graphics, kHealthFillX, kHealthFillY

      if @damage
        x = kHealthFillX + px-to-game @fill-offset @current-health - @damage
        @damage-fill-sprite.draw graphics, x, kHealthFillY

    (new NumberSprite.HUDNumber graphics, @current-health, 2).draw graphics,
      kHealthNumX,  kHealthNumY

