
require! \SDL
require! \std

Game = require \./game

module.exports = class Sprite
  (graphics, path, source-x, source-y, @width, @height) ->
    @source-rect  = new SDL.Rect source-x, source-y, width, height
    @sprite-sheet = graphics.load-image path

    if Game.kDebugMode
      document.body.append-child @sprite-sheet.canvas

  draw: (graphics, x, y) ->
    #std.log 'Sprite::draw', x, y, @width, @height
    dest-rect = new SDL.Rect x, y, @width, @height
    graphics.blit-surface @sprite-sheet, @source-rect, dest-rect

