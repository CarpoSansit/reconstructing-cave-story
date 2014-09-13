
#
# Units Helpers
#

require! \std
require! \./config

# TODO: Don't
kTileSize = 32

# Spacial
export Game  = std.id               # Intrinsic units of position.
export Pixel = std.floor            # Discrete
export Tile  = std.abs . std.floor  # Discrete, non-negative

# Time
export FPS = std.id  # Hertz
export MS  = std.id  # milliseconds

# Derivatives
export Velocity     = std.id  # game / ms
export Acceleration = std.id  # game / ms / ms


# Conversion utils

# TODO: Quit assuming 16x16
export game-to-px   = Pixel . (/ 2)
export game-to-tile = Tile . (/ kTileSize)
export tile-to-game = (* kTileSize)
export tile-to-px   = game-to-px . tile-to-game

