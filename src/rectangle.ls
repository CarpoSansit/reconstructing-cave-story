
# Rectangle Class

module.exports = class Rectangle

  (@x, @y, @w, @h) ->
    @top    = @y
    @left   = @x
    @right  = @x + @w
    @bottom = @y + @h

