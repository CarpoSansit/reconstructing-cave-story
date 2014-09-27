
#
# Map Collidable
#

require! \std
require! \./units

{ InterfaceError } = std
{ WALL_TILE }      = require \./map


# Constants

[ TOP, BOTTOM, LEFT, RIGHT ] = std.enum
export Side = { TOP, BOTTOM, LEFT, RIGHT }


# Helpers - make the box getters later on much shorter. I can't read huge lines.

top-box    = (rect, x, y, Δ) -> rect.top-collision    x.position, y.position, Δ
left-box   = (rect, x, y, Δ) -> rect.left-collision   x.position, y.position, Δ
right-box  = (rect, x, y, Δ) -> rect.right-collision  x.position, y.position, Δ
bottom-box = (rect, x, y, Δ) -> rect.bottom-collision x.position, y.position, Δ


# MapCollidable

export class MapCollidable
  ->

  on-collision: -> throw new InterfaceError "MapCollidable - `on-collision` method not implemented"
  on-delta:     -> throw new InterfaceError "MapCollidable - `on-delta` method not implemented"

  on-wall-collision: (map, rect, λ) ->
    for tile in map.get-colliding-tiles rect
      if tile.type is WALL_TILE
        return λ.call this, tile
    λ.call this

  update-x: (rect, kx, ky, elapsed-time, map) ->

    Δx = kx.velocity * elapsed-time

    if Δx > 0
      @on-wall-collision map, (right-box rect, kx, ky, Δx), (tile) ->
        if tile
          kx.position = units.tile-to-game(tile.col) - rect.bounding-box.right
          @on-collision Side.RIGHT, yes
        else
          kx.position += Δx
          @on-delta Side.RIGHT

      @on-wall-collision map, (left-box rect, kx, ky, 0), (tile) ->
        if tile
          kx.position = units.tile-to-game(tile.col + 1) - rect.bounding-box.left
          @on-collision Side.LEFT, no

    else
      @on-wall-collision map, (left-box rect, kx, ky, Δx), (tile) ->
        if tile
          kx.position = units.tile-to-game(tile.col + 1) - rect.bounding-box.left
          @on-collision Side.LEFT, yes
        else
          kx.position += Δx
          @on-delta Side.LEFT

      @on-wall-collision map, (right-box rect, kx, ky, 0), (tile) ->
        if tile
          kx.position = units.tile-to-game(tile.col) - rect.bounding-box.right
          @on-collision Side.RIGHT, no

  update-y: (rect, kx, ky, elapsed-time, map) ->


    Δy = ky.velocity * elapsed-time

    # Falling
    if Δy > 0
      @on-wall-collision map, (bottom-box rect, kx, ky, Δy), (tile) ->
        if tile
          ky.position = units.tile-to-game(tile.row) - rect.bounding-box.bottom
          @on-collision Side.BOTTOM, yes
        else
          ky.position += Δy
          @on-delta Side.BOTTOM

      @on-wall-collision map, (top-box rect, kx, ky, 0), (tile) ->
        if tile
          ky.position = units.tile-to-game(tile.row + 1) + rect.bounding-box.top
          @on-collision Side.TOP, no

    # Jumping
    else
      @on-wall-collision map, (top-box rect, kx, ky, Δy), (tile) ->
        if tile
          ky.position = units.tile-to-game(tile.row + 1) + rect.bounding-box.top
          @on-collision Side.TOP, yes
        else
          ky.position += Δy
          @on-delta Side.TOP

      @on-wall-collision map, (bottom-box rect, kx, ky, 0), (tile) ->
        if tile
          ky.position = units.tile-to-game(tile.row) - rect.bottom-collision.bottom
          @on-collision Side.BOTTOM, no

