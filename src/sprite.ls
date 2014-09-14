
#
# Sprite
#

require! \SDL
require! \std
require! \./units

{ div } = std
{ kHalfTile, tile-to-px, game-to-px } = units


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


# NumberSprite
#
# For drawing numbers like on the healt HUD

export class NumberSprite

  kDigitSrcY      = tile-to-px 3.5
  kDigitSrcWidth  = tile-to-px 0.5
  kDigitSrcHeight = tile-to-px 0.5
  kDigitSize      = units.kHalfTile

  # NumberSprite (Graphics, Number) -> NumberSprite
  #
  # len is the expected length of the number so we can right-align the output.
  # If len is zero then it's left-aligned instead, and can be as long as it
  # wants. We don't handle the case where len lies about the number.

  (graphics, @num, @len = 0) ->
    @digits = NumberSprite.seperate-digits @num
    @num-digits = @digits.length
    @padding = if @len is 0 then 0 else kDigitSize * (@len - @num-digits)
    @glyphs = @digits.map ->
      new Sprite graphics, 'data/16x16/TextBox.bmp',
        tile-to-px(0.5 * it), kDigitSrcY, kDigitSrcWidth, kDigitSrcHeight

  # NumberSprite::draw (Graphics, Game, Game)
  draw: (graphics, x, y) ->
    for glyph, i in @glyphs
      offset = kDigitSize * (@digits.length - 1 - i)
      glyph.draw graphics, x + @padding + offset, y

  # NumberSprite.seperate-digits (Number) -> Array
  @seperate-digits = (num) ->
    if num is 0
      [ 0 ]
    else
      while num isnt 0
        digit = num % 10
        num := num `div` 10
        digit

