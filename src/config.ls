
#
# Config
#

# Config is just raw data - in fact I might make it JSON later on - but the
# point is it has no dependencies so it can't cause problems via cirular
# requiring. This solves the problem we have with Game that Chris and people
# using compiled languages don't have, which is that Game used to provide stuff
# like kScreenWidth, but also required other modules which needed to know
# kScreenWidth. If Game requires those module before it's done defining itself,
# kScreenWidth isn't available except in later, post-init function calls to the
# module scope. Unlike C++, where the compiler makes everything available up
# front, we have to plan for run-time.

export kScreenWidth  = 20  # Tiles
export kScreenHeight = 15  # Tiles

export kFps          = 60
export kMaxFrameTime = 5 * 1000 / kFps

export kGraphicsQuality = 32


# Debug Flags

# Take global env variable into account if it exists. This way someone can put
# ENABLE_DEBUG_FEATURES anywhere on the page to set these options to true. I
# might make this more granular later.

console.log ENABLE_DEBUG_FEATURES

export debug-features    = if ENABLE_DEBUG_FEATURES? then that else no
export show-collisions   = debug-features
export show-spritesheets = debug-features
export show-readout      = debug-features


# Asset paths

switch kGraphicsQuality
| 16 =>
  export asset-path = 'data/16x16/'
  export file-ext   = '.bmp'

| 32 =>
  export asset-path = 'data/32x32/'
  export file-ext   = '.bmp'

export find-asset = (asset-path +) . (+ file-ext)

