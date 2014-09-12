
# Require

require! \std

{ div } = std

Game   = require \./game
Rect   = require \./rectangle
Sprite = require \./sprite


# Constants

[ AIR_TILE, WALL_TILE ] = std.enum


# Private class: Tile

class Tile
  (@type = AIR_TILE, @sprite) ->


# Private class: CollisionTile

class CollisionTile
  (@row, @col, @type) ->


# Map class

module.exports = class Map

  ->
    @tiles = Map.create-matrix 20, 15

  update: (elapsed-time) ->
    for row in @tiles
      for tile in row
        tile.sprite?.update elapsed-time

  draw: (graphics) ->
    for row, y in @tiles
      for tile, x in row
        tile.sprite?.draw graphics, x * Game.kTileSize, y * Game.kTileSize

  get-colliding-tiles: (rect) ->
    first-row = rectangle.top    `div` Game.kTileSize
    last-row  = rectangle.bottom `div` Game.kTileSize
    first-col = rectangle.left   `div` Game.kTileSize
    last-col  = rectangle.right  `div` Game.kTileSize
    collision-tiles = []

    for row from first-row to last-row
      for col from first-col to last-col
        collision-tiles.push new CollisionTile row, col, @tiles[row][col].type

    return collision-tiles

  @create-test-map = (graphics) ->

    map = new Map

    num-rows = 15
    num-cols = 20

    row = 11

    # Basic block
    tile = new Tile WALL_TILE, new Sprite graphics, 'content/PrtCave.bmp',
      Game.kTileSize, 0,
      Game.kTileSize, Game.kTileSize

    # Floor
    for col from 0 to num-cols
      map.tiles[row][col] = tile

    # Steps
    map.tiles[10][5] = tile
    map.tiles[9][4]  = tile
    map.tiles[8][3]  = tile
    map.tiles[7][2]  = tile
    map.tiles[10][3] = tile

    return map

  @create-matrix = (cols, rows) ->
    for y from 0 to rows
      for z from 0 to cols
        new Tile

