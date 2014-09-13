
#
# Sprite
#

require! \SDL
require! \std
require! \./units


# Sprite class

module.exports = class Sprite

  # Sprite (Graphics, String, Pixel, Pixel, Pixel, Pixel)
  (graphics, path, source-x, source-y, @width, @height) ->
    @source-rect  = new SDL.Rect source-x, source-y, width, height
    @sprite-sheet = graphics.load-image path, true

  # Sprite::update (abstract)
  update: ->

  # Sprite::draw (Graphics, GameUnit, GameUnit)
  draw: (graphics, x, y) ->
    dest-rect = new SDL.Rect units.game-to-px(x), units.game-to-px(y), @width, @height
    graphics.blit-surface @sprite-sheet, @source-rect, dest-rect

