
# Backdrop
#
# Various types of background effects

require! \std
require! \SDL
require! \./units
require! \./config


# Reference constants

{ kScreenWidth, kScreenHeight } = config

kBackgroundSize = 4  # Tiles


# Backdrop
#
# In the C++ version, Backdrop is an abstract class that specifies a 'draw'
# interface. We can do this in Livescript with `implements`, but its pointless
# unless we actually have some supermethods to take advantage of. Maybe later.

# class Backdrop
#   ->
#   draw: (graphics) ->


# FixedBackdrop
#
# A simple backdrop with a static tiled graphic

export class FixedBackdrop

  # Backdrop (String, Graphics)
  (path, graphics) ->
    @surface = graphics.load-image path

  # Backdrop::draw (Graphics)
  draw: (graphics) ->
    for x from 0 to units.tile-to-px(kScreenWidth + kBackgroundSize) by units.tile-to-px(kBackgroundSize)
      for y from 0 to units.tile-to-px(kScreenHeight + kBackgroundSize) by units.tile-to-px(kBackgroundSize)
        dest-rect = new SDL.Rect x, y, units.tile-to-px(kBackgroundSize), units.tile-to-px(kBackgroundSize)
        graphics.blit-surface @surface, null, dest-rect

