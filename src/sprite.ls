
require! \SDL
require! \std

module.exports = class Sprite
  (asset, source-x, source-y, @width, @height) ->
    @source-rect  = new SDL.Rect source-x, source-y, width, height
    @sprite-sheet = SDL.load-image asset.data

  draw: (graphics, x, y) ->
    dest-rect = new SDL.Rect x, y, @width, @height
    graphics.blit-surface @sprite-sheet, @source-rect, dest-rect

