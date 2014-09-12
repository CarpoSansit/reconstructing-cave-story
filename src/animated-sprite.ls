
require! \std

Game   = require \./game
Sprite = require \./sprite


module.exports = class AnimatedSprite extends Sprite

  (graphics, path, source-x, source-y, @width, @height, @fps, @num-frames) ->

    #std.log 'AnimatedSprite::New -', source-x, source-y, @width, @height
    super ...

    @frame-time    = 1000 / @fps
    @current-frame = 0
    @elapsed-time  = 0


  update: (elapsed-time) ->
    @elapsed-time += elapsed-time

    if @elapsed-time > @frame-time
      @current-frame += 1
      @elapsed-time = 0

      if @current-frame < @num-frames
        @source-rect.x += Game.kTileSize
      else
        @source-rect.x -= Game.kTileSize * (@num-frames - 1)
        @current-frame = 0

