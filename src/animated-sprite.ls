
#
# Animated Sprite
#

require! \std
require! \./units

Sprite = require \./sprite


# AnimatedSprite Class

module.exports = class AnimatedSprite extends Sprite

  # AnimatedSprite (Graphics, String, Pixel, Pixel, Pixel, Pixel, FSP, Number)
  (graphics, path, source-x, source-y, @width, @height, @fps, @num-frames) ->

    super ...

    @frame-time    = 1000 / @fps
    @current-frame = 0
    @elapsed-time  = 0

  # Update (ms)
  update: (elapsed-time) ->
    @elapsed-time += elapsed-time

    if @elapsed-time > @frame-time
      @current-frame += 1
      @elapsed-time = 0

      if @current-frame < @num-frames
        @source-rect.x += @source-rect.w
      else
        @source-rect.x -= @source-rect.w * (@num-frames - 1)
        @current-frame = 0

