
# SDL Mock - Rectangle

module.exports = class Rect
  (@x, @y, @w, @h) ->

  @clone = ({ x, y, w, h }) -> new Rect x, y, w, h

