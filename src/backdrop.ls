
# Backdrop - various types of background effects

require! \std
require! \SDL

{ kTileSize } = require \./game


# Const

kBackgroundSize = kTileSize * 4



# Backdrop class - abstract, don't instance directly

export class Backdrop
  ->
  draw: ->





# FixedBackdrop - a simple backdrop with a static tiled image

export class FixedBackdrop

  (path, graphics) ->
    @surface = graphics.load-image path


  draw: (graphics) ->
    screen-width  = 640
    screen-height = 320

    for x from 0 to screen-width + kBackgroundSize by kBackgroundSize
      for y from 0 to screen-height + kBackgroundSize by kBackgroundSize
        dest-rect = new SDL.Rect x, y, kBackgroundSize, kBackgroundSize
        graphics.blit-surface @surface, null, dest-rect

