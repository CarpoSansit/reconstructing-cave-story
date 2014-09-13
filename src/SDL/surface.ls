
# Require

require! \std

Rect = require \./rect


# Helpers

make-transparent = (data, color) ->
  canvas = document.create-element \canvas
  canvas.width = data.width
  canvas.height = data.height

  context = canvas.get-context \2d
  context.draw-image data, 0, 0
  pixels = context.get-image-data 0, 0, canvas.width, canvas.height

  for i from 0 to pixels.data.length by 4
    if pixels.data[i+0] is color[0] and
       pixels.data[i+1] is color[1] and
       pixels.data[i+2] is color[2]
        pixels.data[i+3] = 0

  context.put-image-data pixels, 0, 0
  return canvas


# Surface Class

module.exports = class Surface

  (src, @width, @height) ->
    @canvas    = document.create-element \canvas
    @ctx       = @canvas.get-context \2d
    @ready     = no
    @color-key = null

    @reset-canvas-size!

    # Show unloaded surfaces as red
    @ctx.fill-style = \red
    @ctx.fill-rect 0, 0, @width, @height

    if typeof src is \string
      #std.log 'SDL::Surface - src unloaded. Loading...', src
      @load-image-data src
    else if src?
      #std.log 'SDL::Surface - src already prepared:', src
      @save-image-data src
    else
      #std.log 'SDL::Surface - Blank surface created'

  reset-canvas-size: ->
    @canvas.width  = @width  or 100
    @canvas.height = @height or 100

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
    data.onerror = ~>
      std.log "Cant load:", path
      @ctx.fill-rect 0, 0, @width, @height
    data.src = path

  save-image-data: (data) ->
    @data = if @color-key then make-transparent data, @color-key else data
    @ready = yes
    @ctx.clear-rect 0, 0, @width, @height
    @ctx.draw-image @data, 0, 0, @width, @height

  set-color-key: (color) ->
    @color-key = color
    if @ready then @save-image-data @data

  draw-rect: (rect, color = \black) ->
    @ctx.fill-style = color
    @ctx.fill-rect rect.x, rect.y, rect.w, rect.h

  draw-box: (rect, color = \black) ->
    @ctx.stroke-style = color
    @ctx.begin-path!
    @ctx.move-to  0.5 + rect.x,           0.5 + rect.y
    @ctx.line-to  0.5 + rect.x,          -0.5 + rect.y + rect.h
    @ctx.line-to -0.5 + rect.x + rect.w, -0.5 + rect.y + rect.h
    @ctx.line-to -0.5 + rect.x + rect.w,  0.5 + rect.y
    @ctx.line-to  0.5 + rect.x,           0.5 + rect.y
    @ctx.stroke!
    @ctx.close-path!

  clear: ->
    @ctx.clear-rect 0, 0, @width, @height

  @set-color-key = (surface, color) ->
    surface.set-color-key color

  @blit-surface = (source, src-rect, dest, dest-rect) ->
    #std.log 'blit:', src-rect, dest-rect
    if src-rect
      dest.ctx.draw-image source.canvas,
        src-rect.x,  src-rect.y,  src-rect.w,  src-rect.h,
        dest-rect.x, dest-rect.y, dest-rect.w, dest-rect.h
    else
      dest.ctx.draw-image source.canvas,
        dest-rect.x, dest-rect.y, dest-rect.w, dest-rect.h

  @load-image = (path) ->
    new Surface path

