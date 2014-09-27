
#
# Gun Experience HUD
#
# Just view concerns here

require! \std
require! \./units

{ div } = std
{ tile-to-game, tile-to-px:tpx, game-to-px, kHalfTile } = units

{ Timer }        = require \./timer

{ Sprite, NumberSprite, VaryingWidthSprite } = require \./sprite


# Constants

kDrawY       = tile-to-game 1.5
kLvDrawX     = tile-to-game 1.0
kBarDrawX    = tile-to-game 2.5
kLvlNumDrawX = tile-to-game 2.0
kFlashTime   = 800
kFlashPeriod = 40


# Sprite sources

kSpriteName = \TextBox

kBarSrcWidth  = 2.5
kBarSrcHeight = 0.5

kBarSrcX   = 0.0
kBarSrcY   = 4.5
kFlashSrcX = 2.5
kFlashSrcY = 5.0
kMaxSrcX   = 2.5
kMaxSrcY   = 4.5
kFillSrcX  = 0.0
kFillSrcY  = 5.0

# This one in terms of Game becuase of unusual sprite placement
kLvlSrcX      = tile-to-game 5
kLvlSrcY      = 160
kLvlSrcWidth  = tile-to-game 1
kLvlSrcHeight = tile-to-game 0.5


# GunExperienceHUD

export class GunExperienceHUD
  (graphics, level-xp, max-xp) ->
    @xp-bar-sprite = new Sprite graphics, kSpriteName,
      tpx(kBarSrcX), tpx(kBarSrcY), tpx(kBarSrcWidth), tpx(kBarSrcHeight)
    @lv-sprite  = new Sprite graphics, kSpriteName,
      game-to-px(kLvlSrcX), game-to-px(kLvlSrcY), game-to-px(kLvlSrcWidth), game-to-px(kLvlSrcHeight)
    @flash-sprite = new Sprite graphics, kSpriteName,
      tpx(kFlashSrcX), tpx(kFlashSrcY), tpx(kBarSrcWidth), tpx(kBarSrcHeight)
    @max-sprite = new Sprite graphics, kSpriteName,
      tpx(kMaxSrcX), tpx(kMaxSrcY), tpx(kBarSrcWidth), tpx(kBarSrcHeight)
    @fill-sprite = new VaryingWidthSprite graphics, kSpriteName,
      tpx(kFillSrcX), tpx(kFillSrcY), tpx(kBarSrcWidth), tpx(kBarSrcHeight)

    @flash-timer   = new Timer kFlashTime

  activate-flash: ->
    @flash-timer.reset!

  draw: (graphics, gun-lvl, current-xp, level-xp) ->
    @lv-sprite.draw     graphics, kLvDrawX,  kDrawY
    @xp-bar-sprite.draw graphics, kBarDrawX, kDrawY

    NumberSprite.HUDNumber graphics, gun-lvl, 1 .draw graphics, kLvlNumDrawX, kDrawY

    if current-xp < level-xp
      @fill-sprite.set-percentage-width current-xp / level-xp
      @fill-sprite.draw graphics, kBarDrawX, kDrawY
    else
      @max-sprite.draw  graphics, kBarDrawX, kDrawY

    if @flash-timer.is-active and (@flash-timer.current-time `div` kFlashPeriod) % 2 is 0
      @flash-sprite.draw graphics, kBarDrawX, kDrawY

