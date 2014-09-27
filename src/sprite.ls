
#
# Sprite
#

require! \SDL
require! \std
require! \./units

{ div } = std
{ kHalfTile, tile-to-px, game-to-px } = units

{ Timer } = require \./timer
{ Rectangle: Rect, SpriteSource } = require \./rectangle


# Sprite class
#
# Static sprite ust defines a chunk of pixels to use from a given spritesheet

export class Sprite

  (graphics, path, @src) ->
    @source-rect  = new SDL.Rect.clone @src
    @sprite-sheet = graphics.load-image path, true

  update: ->

  draw: (graphics, x, y) ->
    dest-rect = new SDL.Rect game-to-px(x), game-to-px(y), @src.w, @src.h
    graphics.blit-surface @sprite-sheet, @source-rect, dest-rect


# AnimatedSprite class
#
# Moves the blip coordinates according to a given pattern to create animation

export class AnimatedSprite extends Sprite

  (graphics, path, @src, @fps, @keyframes) ->

    super ...

    @frame-timer      = new Timer 1000 / @fps
    @current-frame    = 0
    @current-keyframe = @keyframes[0]
    @origin-x         = @src.x
    @num-completed-loops = 0

  draw: (graphics, x, y, frame-offset = @current-keyframe) ->
    @source-rect.x = @origin-x + frame-offset * @source-rect.w
    dest-rect = new SDL.Rect game-to-px(x), game-to-px(y), @src.w, @src.h
    graphics.blit-surface @sprite-sheet, @source-rect, dest-rect

  update: ->
    if @frame-timer.is-expired
      @frame-timer.reset!
      @current-frame += 1
      if @current-frame >= @keyframes.length
        @num-completed-loops += 1
        @current-frame = 0
      @current-keyframe = @keyframes[ @current-frame ]


# NumberSprite
#
# For drawing numbers like on the healt HUD

export class NumberSprite

  kDigitSrcY      = 3.5
  kOpPlusSrcX     = 2
  kOpMinusSrcX    = 2.5
  kOpSrcY         = 3

  kDigitSize      = units.kHalfTile
  kRadix          = 10

  [ WHITE, RED ] = std.enum
  [ PLUS, MINUS, NONE ] = std.enum


  # NumberSprite (Graphics, Number) -> NumberSprite
  #
  # len is the expected length of the number so we can right-align the output.
  # If len is zero then it's left-aligned instead, and can be as long as it
  # wants. We don't handle the case where len lies about the number.

  (graphics, @num, @len, @color, @op) ->
    @digits     = NumberSprite.seperate-digits @num
    @num-digits = @digits.length
    @padding    = if @len is 0 then 0 else kDigitSize * (@len - @num-digits)

    # Choose color
    srcY = if @color is WHITE then kDigitSrcY else kDigitSrcY + 0.5

    @glyphs = @digits.map ->
      new Sprite graphics, \TextBox, new SpriteSource 0.5 * it, srcY, 0.5, 0.5

    # Add operators for damage/experience numbers
    if @op is PLUS
      @glyphs.push new Sprite graphics, \TextBox,
        new SpriteSource kOpPlusSrcX, kOpSrcY, 0.5, 0.5

    if @op is MINUS
      @glyphs.push new Sprite graphics, \TextBox,
        new SpriteSource kOpMinusSrcX, kOpSrcY, 0.5, 0.5

    @width  = kHalfTile * @glyphs.length
    @height = kHalfTile

  draw: (graphics, x, y) ->
    for glyph, i in @glyphs
      offset = kDigitSize * (@glyphs.length - 1 - i)
      glyph.draw graphics, x + @padding + offset, y

  draw-centered: (graphics, x, y) ->
    @draw graphics, x - @width/2, y - @height/2

  @seperate-digits = (num) ->
    if num is 0
      [ 0 ]
    else
      while num isnt 0
        digit = num % kRadix
        num := num `div` kRadix
        digit

  # 'Named Constructors'

  @HUDNumber = (graphics, @num, @len) ->
    new NumberSprite graphics, @num, @len, WHITE, NONE

  @DamageNumber = (graphics, @num) ->
    new NumberSprite graphics, @num, 0, RED, MINUS

  @ExperienceNumber = (graphics, @num) ->
    new NumberSprite graphics, @num, 0, WHITE, PLUS


# VaryingWidthSprite
#
# Control width of drawn region on the fly

export class VaryingWidthSprite extends Sprite

  (graphics, path, source-x, source-y, @initial-width, @height) ->
    super ...
    @width = @initial-width

  set-width: (width) ->
    @width = width

  #draw: (graphics) ->


