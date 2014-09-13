
#
# Rectangle
#

# No dependencies


# Rectangle Class

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

