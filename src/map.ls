
# Require

require! \std

Game   = require \./game
Sprite = require \./sprite


# Map class

module.exports = class Map

  ->
    # Assumption: this array is an appropriate size
    @foreground = Map.create-matrix 20, 15

  update: (elapsed-time) ->
    for row in @foreground
      for cell in row
        cell?.update elapsed-time

  draw: (graphics) ->
    for row, y in @foreground
      for cell, x in row
        cell?.draw graphics, x * Game.kTileSize, y * Game.kTileSize

  @create-test-map = (graphics) ->

    map = new Map

    num-rows = 15
    num-cols = 20

    row = 11

    # Basic block
    sprite = new Sprite graphics, 'content/PrtCave.bmp',
      Game.kTileSize, 0,
      Game.kTileSize, Game.kTileSize

    # Floor
    for col from 0 to num-cols
      map.foreground[row][col] = sprite

    # Steps
    map.foreground[10][5] = sprite
    map.foreground[9][4] = sprite
    map.foreground[8][3] = sprite
    map.foreground[7][2] = sprite
    map.foreground[10][3] = sprite

    return map

  @create-matrix = (cols, rows) ->
    for y from 0 to rows
      for z from 0 to cols
        null

