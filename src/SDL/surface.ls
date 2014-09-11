
# Require

require! \std

Rect = require \./rect


# Surface Class

module.exports = class Surface

  (@image, @width, @height) ->

    #std.log 'SDL::Surface - new:', @image

    @canvas = document.create-element \canvas
    @ctx    = @canvas.get-context \2d

    @canvas.width  = @width
    @canvas.height = @height

    if @image?
      @ctx.draw-image @image, 0, 0, @width, @height

  clear: ->
    @ctx.clear-rect 0, 0, @width, @height

  @blit-surface = (source, src-rect, dest, dest-rect) ->
    dest.ctx.draw-image source.canvas,
      src-rect.x, src-rect.y, src-rect.w, src-rect.h,
      dest-rect.x, dest-rect.y, dest-rect.w, dest-rect.h

