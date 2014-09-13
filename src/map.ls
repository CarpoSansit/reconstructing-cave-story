
# Require

require! \std

{ div } = std

Game   = require \./game
Rect   = require \./rectangle
Sprite = require \./sprite

{ FixedBackdrop } = require \./backdrop


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
    @backdrop = null
    @tiles    = Map.create-matrix (new Tile), 20, 15
    @bg-tiles = Map.create-matrix null, 20, 15

  update: (elapsed-time) ->
    for row in @tiles
      for tile in row
        tile.sprite?.update elapsed-time

  draw: (graphics) ->
    for row, y in @tiles
      for tile, x in row
        tile.sprite?.draw graphics, x * Game.kTileSize, y * Game.kTileSize

  draw-background: (graphics) ->
    @backdrop.draw graphics

    for row, y in @bg-tiles
      for sprite, x in row
        sprite?.draw graphics, x * Game.kTileSize, y * Game.kTileSize

  get-colliding-tiles: (rect) ->
    first-row = rect.top    `div` Game.kTileSize
    last-row  = rect.bottom `div` Game.kTileSize
    first-col = rect.left   `div` Game.kTileSize
    last-col  = rect.right  `div` Game.kTileSize
    collision-tiles = []

    for row from first-row to last-row
      for col from first-col to last-col
        collision-tiles.push new CollisionTile row, col, @tiles[row][col].type

    return collision-tiles

  @create-test-map = (graphics) ->

    # new map
    map = new Map

    # Create imple backdrop
    map.backdrop = new FixedBackdrop 'data/16x16/bkBlue.bmp', graphics

    # Create tile layout
    num-rows = 15
    num-cols = 20
    row = 11

    # Basic block
    tile = new Tile WALL_TILE, new Sprite graphics, 'data/16x16/Stage/PrtCave.bmp',
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

    # Background tiles
    chain-top = new Sprite graphics, 'data/16x16/Stage/PrtCave.bmp', 11 * Game.kTileSize, 2 * Game.kTileSize, Game.kTileSize, Game.kTileSize
    chain-mid = new Sprite graphics, 'data/16x16/Stage/PrtCave.bmp', 12 * Game.kTileSize, 2 * Game.kTileSize, Game.kTileSize, Game.kTileSize
    chain-btm = new Sprite graphics, 'data/16x16/Stage/PrtCave.bmp', 13 * Game.kTileSize, 2 * Game.kTileSize, Game.kTileSize, Game.kTileSize

    map.bg-tiles[8][2] = chain-top
    map.bg-tiles[9][2] = chain-mid
    map.bg-tiles[10][2] = chain-btm

    return map

  @create-matrix = (value, cols, rows) ->
    [ [ value for z from 0 to cols ] for y from 0 to rows ]

  @WALL_TILE = WALL_TILE
  @AIR_TILE  = AIR_TILE

