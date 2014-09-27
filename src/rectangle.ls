
#
# Rectangle
#

require! \./units


# Rectangle Class
#
# Generic rectangle as a container for vector boxes. Takes an optional
# multiplier for easy scaling, and supplies results in a variety of dialects.

export class Rectangle

  # Rectangle (Game, Game, Game, Game, ?Number)
  (x, y, w, h, m = 1) ->
    @x      = x * m
    @y      = y * m
    @w      = w * m
    @h      = h * m
    @top    = @y
    @left   = @x
    @right  = @x + @w
    @bottom = @y + @h

  # Rectangle::collides-with (Rectangle)
  collides-with: (other) ->
    @right >= other.left and
      @left <= other.right and
      @top <= other.bottom and
      @bottom >= other.top


# SpriteSource
#
# A special rectanlge used to clean up the definition of sprite regions.
# Instead of having kSourceX, kSourceY, etc etc in every files, lets just have
# new SpriteSource x, y, w, h.

export class SpriteSource

  (tile-x, tile-y, tile-w = 1, tile-h = 1) ->
    @x = units.tile-to-px tile-x
    @y = units.tile-to-px tile-y
    @w = units.tile-to-px tile-w
    @h = units.tile-to-px tile-h

