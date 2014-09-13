
# Require

require! \std

Rect = require \./rect


# Surface Class

module.exports = class Surface

  (src, @width, @height) ->
    @canvas = document.create-element \canvas
    @ctx    = @canvas.get-context \2d
    @ready  = no

    @reset-canvas-size!

    if typeof src is \string
      #std.log 'SDL::Surface - src unloaded. Loading...', src
      @load-image-data src
    else if src?
      #std.log 'SDL::Surface - src already prepared:', src
      @save-image-data src
    else
      #std.log 'SDL::Surface - Blank surface created'

  reset-canvas-size: ->
    @canvas.width  = @width
    @canvas.height = @height

  inherit-size-from-image: (data) ->
    if not @width? and not @height?
      @width  = data.naturalWidth
      @height = data.naturalHeight
      @reset-canvas-size!

  load-image-data: (path) ->
    data = new Image
    data.onload = ~>
      #std.log 'SDL::Surface::loadImageData - asset ready:', path
      @inherit-size-from-image data
      @save-image-data data
    data.src = path

  save-image-data: (data) ->
    #std.log 'SDL::Surface::saveImageData -', data
    @data  = data
    @ready = yes
    @ctx.draw-image @data, 0, 0, @width, @height

  clear: ->
    @ctx.clear-rect 0, 0, @width, @height

  @blit-surface = (source, src-rect, dest, dest-rect) ->
    #std.log 'blit:', src-rect, dest-rect
    if src-rect
      dest.ctx.draw-image source.canvas,
        src-rect.x,  src-rect.y,  src-rect.w,  src-rect.h,
        dest-rect.x, dest-rect.y, dest-rect.w, dest-rect.h
    else
      dest.ctx.draw-image source.canvas,
        dest-rect.x, dest-rect.y, dest-rect.w, dest-rect.h
