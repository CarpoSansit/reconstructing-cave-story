
#
# Sprite
#

require! \SDL
require! \std
require! \./units

{ div } = std
{ kHalfTile, tile-to-px, game-to-px } = units

{ Timer } = require \./timer
{ Rectangle: Rect } = require \./rectangle


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
  (graphics, path, source-x, source-y, @width, @height, @fps, @keyframes) ->

    super ...

    @frame-timer      = new Timer 1000 / @fps
    @current-frame    = 0
    @current-keyframe = @keyframes[0]
    @origin-x         = @source-rect.x

  # Sprite::draw (Graphics, GameUnit, GameUnit, Number)
  draw: (graphics, x, y, frame-offset = @current-keyframe) ->
    @source-rect.x = @origin-x + frame-offset * @source-rect.w
    dest-rect = new SDL.Rect units.game-to-px(x), units.game-to-px(y), @width, @height
    graphics.blit-surface @sprite-sheet, @source-rect, dest-rect

  # Update (ms)
  update: ->
    if @frame-timer.is-expired
      @frame-timer.reset!
      @current-frame += 1
      if @current-frame >= @keyframes.length then @current-frame = 0
      @current-keyframe = @keyframes[ @current-frame ]


# NumberSprite
#
# For drawing numbers like on the healt HUD

export class NumberSprite

  kDigitSrcY      = tile-to-px 3.5
  kDigitSrcWidth  = tile-to-px 0.5
  kDigitSrcHeight = tile-to-px 0.5
  kOpPlusSrcX     = tile-to-px 2
  kOpMinusSrcX    = tile-to-px 2.5
  kOpSrcY         = tile-to-px 3
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
    @digits = NumberSprite.seperate-digits @num
    @num-digits = @digits.length
    @padding = if @len is 0 then 0 else kDigitSize * (@len - @num-digits)

    # Choose color
    srcY = if @color is WHITE then kDigitSrcY else kDigitSrcY + game-to-px kHalfTile

    @glyphs = @digits.map ->
      new Sprite graphics, \TextBox,
        tile-to-px(0.5 * it), srcY, kDigitSrcWidth, kDigitSrcHeight

    # Add operators for damage/experience numbers
    if @op is PLUS
      @glyphs.push new Sprite graphics, \TextBox,
        kOpPlusSrcX, kOpSrcY, kDigitSrcWidth, kDigitSrcHeight

    if @op is MINUS
      @glyphs.push new Sprite graphics, \TextBox,
        kOpMinusSrcX, kOpSrcY, kDigitSrcWidth, kDigitSrcHeight

    @width  = kHalfTile * @glyphs.length
    @height = kHalfTile

  # NumberSprite::draw (Graphics, Game, Game)
  draw: (graphics, x, y) ->
    for glyph, i in @glyphs
      offset = kDigitSize * (@glyphs.length - 1 - i)
      glyph.draw graphics, x + @padding + offset, y

  draw-centered: (graphics, x, y) ->
    @draw graphics, x - @width/2, y - @height/2

  # NumberSprite.seperate-digits (Number) -> Array
  @seperate-digits = (num) ->
    if num is 0
      [ 0 ]
    else
      while num isnt 0
        digit = num % kRadix
        num := num `div` kRadix
        digit

  # 'Named Constructors'

  # NumberSprite.HUDNumber (Graphics, Number, Number)
  @HUDNumber = (graphics, @num, @len) ->
    new NumberSprite graphics, @num, @len, WHITE, NONE

  # NumberSprite.DamageNumber (Graphics, Number)
  @DamageNumber = (graphics, @num) ->
    new NumberSprite graphics, @num, 0, RED, MINUS

  # NumberSprite.ExperienceNumber (Graphics, Number)
  @ExperienceNumber = (graphics, @num) ->
    new NumberSprite graphics, @num, 0, WHITE, PLUS


# VaryingWidthSprite
#
# Control width of drawn region on the fly

export class VaryingWidthSprite extends Sprite

  # VaryingWidthSprite : Sprite (Graphics)
  (graphics, path, source-x, source-y, @initial-width, @height) ->

    super ...
    @width = @initial-width

  # VaryingWidthSprite::set-width (Pixels)
  set-width: (width) ->
    @width = width

  # VaryingWidthSprite::draw (Graphics)
  #draw: (graphics) ->




