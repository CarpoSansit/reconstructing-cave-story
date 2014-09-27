
#
# Gun Experience HUD
#
# Just view concerns here

require! \std
require! \./units

{ div } = std
{ tile-to-game, tile-to-px, game-to-px, kHalfTile } = units

{ Timer }        = require \./timer
{ SpriteSource } = require \./rectangle

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

kBarSrc   = new SpriteSource 0.0, 4.5, 2.5, 0.5
kFlashSrc = new SpriteSource 2.5, 5.0, 2.5, 0.5
kLvSrc    = x: tile-to-px(5), y: game-to-px(160), w: tile-to-px(1), h: tile-to-px 0.5


# GunExperienceHUD

export class GunExperienceHUD

  (graphics) ->
    @xp-bar-sprite = new Sprite graphics, kSpriteName, kBarSrc
    @lv-sprite     = new Sprite graphics, kSpriteName, kLvSrc
    @flash-sprite  = new Sprite graphics, kSpriteName, kFlashSrc
    @flash-timer   = new Timer kFlashTime

  activate-flash: ->
    @flash-timer.reset!

  draw: (graphics, gun-lvl) ->
    @lv-sprite.draw     graphics, kLvDrawX,  kDrawY
    @xp-bar-sprite.draw graphics, kBarDrawX, kDrawY
    lvl-num-sprite = NumberSprite.HUDNumber graphics, gun-lvl, 1
    lvl-num-sprite.draw graphics, kLvlNumDrawX, kDrawY

    if @flash-timer.is-active and (@flash-timer.current-time `div` kFlashPeriod) % 2 is 0
      @flash-sprite.draw graphics, kBarDrawX, kDrawY


