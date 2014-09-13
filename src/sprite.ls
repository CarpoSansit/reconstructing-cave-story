
#
# Sprite
#

require! \SDL
require! \std
require! \./units


# Sprite class
#
# Static sprite ust defines a chunk of pixels to use from a given spritesheet

export class Sprite

  # Sprite (Graphics, String, Pixel, Pixel, Pixel, Pixel)
  (graphics, path, source-x, source-y, @width, @height) ->
    @source-rect  = new SDL.Rect source-x, source-y, width, height
    @sprite-sheet = graphics.load-image path, true

  # Sprite::update (abstract)
  update: ->

  # Sprite::draw (Graphics, GameUnit, GameUnit)
  draw: (graphics, x, y) ->
    dest-rect = new SDL.Rect units.game-to-px(x), units.game-to-px(y), @width, @height
    graphics.blit-surface @sprite-sheet, @source-rect, dest-rect


# AnimatedSprite class
#
# Moves the blip coordinates according to a given pattern to create animation

export class AnimatedSprite extends Sprite

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


