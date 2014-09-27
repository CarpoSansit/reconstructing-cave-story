
#
# Units Helpers
#

require! \std
require! \./config

kPi = Math.PI

kGameUnitsPerTile = 32
kPixelScaleFactor = kGameUnitsPerTile / config.kGraphicsQuality


# Spacial
export Game     = std.id               # Intrinsic units of position.
export Pixel    = std.floor            # Discrete
export Tile     = std.abs . std.floor  # Discrete, non-negative
export Degrees  = std.id               # Circular
export GunLevel = std.floor            # Discrete
export GunXP    = std.floor            # Discrete

# Time
export FPS = std.id  # Hertz
export MS  = std.id  # milliseconds

# Derivatives
export Velocity     = std.id  # game / ms
export Acceleration = std.id  # game / ms / ms

# Game Concepts
export HP = std.floor

# Conversion utils
export game-to-px   = Pixel . (/ kPixelScaleFactor)
export game-to-tile = Tile . (/ kGameUnitsPerTile)
export tile-to-game = (* kGameUnitsPerTile)
export tile-to-px   = tile-to-game >> game-to-px
export px-to-game   = (* kPixelScaleFactor)
export px-to-tile   = px-to-game >> (/ kGameUnitsPerTile)
export deg-to-rad   = (* kPi / 180)

# Convenience Constants
export kOneTile     = tile-to-game 1
export kHalfTile    = tile-to-game 0.5
export kTilePx      = tile-to-px 1
export kMaxGunLevel = 3
