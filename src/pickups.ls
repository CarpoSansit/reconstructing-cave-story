
# Require

require! \std
require! \./units


# Pickups collection class

export class Pickups

  ->
    @pickups = []

  update: (elapsed-time, map) ->
    @pickups = @pickups.filter (.update elapsed-time, map)

  add: (pickup) ->
    @pickups.push pickup

  draw: (graphics) ->
    @pickups.map (.draw graphics)

  handle-collisions: (player) ->
    @pickups = @pickups.filter ->
      if player.damage-rectangle.collised-with it.collision-rectangle
        player.collect-pickup it
        return false
      return true

