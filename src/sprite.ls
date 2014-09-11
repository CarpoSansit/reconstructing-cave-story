
require! \SDL
require! \std

module.exports = class Sprite
  (graphics, path, source-x, source-y, @width, @height) ->
    @source-rect  = new SDL.Rect source-x, source-y, width, height
    @sprite-sheet = graphics.load-image path

  draw: (graphics, x, y) ->
    dest-rect = new SDL.Rect x, y, @width, @height
    graphics.blit-surface @sprite-sheet.data, @source-rect, dest-rect

