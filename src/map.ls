
# Require

require! \std
require! \./units

{ div } = std


{ Sprite }          = require \./sprite
{ FixedBackdrop }   = require \./backdrop
{ Rectangle: Rect } = require \./rectangle


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
        tile.sprite?.draw graphics, units.tile-to-game(x), units.tile-to-game(y)

  draw-background: (graphics) ->
    @backdrop.draw graphics

    for row, y in @bg-tiles
      for sprite, x in row
        sprite?.draw graphics, units.tile-to-game(x), units.tile-to-game(y)

  get-colliding-tiles: (rect) ->
    first-row = units.game-to-px(rect.top)    `div` units.tile-to-px(1)
    last-row  = units.game-to-px(rect.bottom) `div` units.tile-to-px(1)
    first-col = units.game-to-px(rect.left)   `div` units.tile-to-px(1)
    last-col  = units.game-to-px(rect.right)  `div` units.tile-to-px(1)
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
      units.tile-to-px(1), 0,
      units.tile-to-px(1), units.tile-to-px(1)

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
    chain-top = new Sprite graphics, 'data/16x16/Stage/PrtCave.bmp', units.tile-to-px(11), units.tile-to-px(2), units.tile-to-px(1), units.tile-to-px(1)
    chain-mid = new Sprite graphics, 'data/16x16/Stage/PrtCave.bmp', units.tile-to-px(12), units.tile-to-px(2), units.tile-to-px(1), units.tile-to-px(1)
    chain-btm = new Sprite graphics, 'data/16x16/Stage/PrtCave.bmp', units.tile-to-px(13), units.tile-to-px(2), units.tile-to-px(1), units.tile-to-px(1)

    map.bg-tiles[8][2] = chain-top
    map.bg-tiles[9][2] = chain-mid
    map.bg-tiles[10][2] = chain-btm

    return map

  @create-matrix = (value, cols, rows) ->
    [ [ value for z from 0 to cols ] for y from 0 to rows ]

  @WALL_TILE = WALL_TILE
  @AIR_TILE  = AIR_TILE

