
#
# Rectangle
#

require! \./units


# Rectangle Class
#
# Generic rectangle as a container for vector boxes. Takes an optional
# multiplier for easy scaling, and supplies results in a variety of dialects.

export class Rectangle

  (x, y, w, h, m = 1) ->
    @x      = x * m
    @y      = y * m
    @w      = w * m
    @h      = h * m
    @top    = @y
    @left   = @x
    @right  = @x + @w
    @bottom = @y + @h

  collides-with: (other) ->
    @right >= other.left and
      @left <= other.right and
      @top <= other.bottom and
      @bottom >= other.top

  translate: (x, y) ->
    new Rectangle @x + x, @y + y, @w, @h

