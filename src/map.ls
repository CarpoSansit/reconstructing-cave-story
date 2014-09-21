
# Require

require! \std
require! \./units

{ div } = std

{ tile-to-px, game-to-px, tile-to-game } = units

{ Sprite }          = require \./sprite
{ FixedBackdrop }   = require \./backdrop
{ Rectangle: Rect } = require \./rectangle


# Constants

[ AIR_TILE, WALL_TILE ] = std.enum

kMapWidth = 20


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
    @tiles    = Map.create-matrix (new Tile), kMapWidth, 15
    @bg-tiles = Map.create-matrix null, kMapWidth, 15

  #update: (elapsed-time) ->
  #  for row in @tiles
  #    for tile in row
  #      tile.sprite?.update elapsed-time

  draw: (graphics) ->
    for row, y in @tiles
      for tile, x in row
        tile.sprite?.draw graphics, tile-to-game(x), tile-to-game(y)

  draw-background: (graphics) ->
    @backdrop.draw graphics

    for row, y in @bg-tiles
      for sprite, x in row
        sprite?.draw graphics, tile-to-game(x), tile-to-game(y)

  get-colliding-tiles: (rect) ->
    first-row = game-to-px(rect.top)    `div` tile-to-px(1)
    last-row  = game-to-px(rect.bottom) `div` tile-to-px(1)
    first-col = game-to-px(rect.left)   `div` tile-to-px(1)
    last-col  = game-to-px(rect.right)  `div` tile-to-px(1)
    collision-tiles = []

    for row from first-row to last-row
      for col from first-col to last-col
        if row < 0 or col < 0 or col >= kMapWidth
          collision-tiles.push new CollisionTile row, col, WALL_TILE
        else
          collision-tiles.push new CollisionTile row, col, @tiles[row][col].type

    return collision-tiles

  @create-test-map = (graphics) ->

    # new map
    map = new Map

    bg-path = 'bkBlue'
    fg-path = 'Stage/PrtCave'

    # Create imple backdrop
    map.backdrop = new FixedBackdrop bg-path, graphics

    # Create tile layout
    num-rows = 15
    num-cols = 20
    row = 11

    # Basic block
    tile = new Tile WALL_TILE, new Sprite graphics, fg-path,
      tile-to-px(1), 0,
      tile-to-px(1), tile-to-px(1)

    # Floor
    for col from 0 to num-cols
      map.tiles[row][col] = tile

    # Steps
    map.tiles[10][5] = tile
    map.tiles[9][4]  = tile
    map.tiles[8][3]  = tile
    map.tiles[7][2]  = tile
    map.tiles[10][3] = tile
    map.tiles[10][0] = tile

    # Background tiles
    chain-top = new Sprite graphics, fg-path, tile-to-px(11), tile-to-px(2), tile-to-px(1), tile-to-px(1)
    chain-mid = new Sprite graphics, fg-path, tile-to-px(12), tile-to-px(2), tile-to-px(1), tile-to-px(1)
    chain-btm = new Sprite graphics, fg-path, tile-to-px(13), tile-to-px(2), tile-to-px(1), tile-to-px(1)
    map.bg-tiles[8][2] = chain-top
    map.bg-tiles[9][2] = chain-mid
    map.bg-tiles[10][2] = chain-btm

    # Done
    return map

  @create-matrix = (value, cols, rows) ->
    [ [ value for z from 0 to cols ] for y from 0 to rows ]

  @WALL_TILE = WALL_TILE
  @AIR_TILE  = AIR_TILE

