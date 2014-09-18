
#
# Graphics
#
# Singleton. The contents of this file are equivalent to the contents of a
# class constructor. We simply delare all functions, and then make public the
# ones we want via `exports`
#

require! \std
require! \SDL
require! \./config
require! \./units


# Reference constants

{ kScreenWidth, kScreenHeight } = config

kTransparentColor  = [ 0, 0, 0 ]
kScreenScaleFactor = if config.kGraphicsQuality is 16 then 2 else 1


# State

spritesheets = {}

screen = SDL.set-video-mode(
  units.tile-to-px(kScreenWidth),
  units.tile-to-px(kScreenHeight),
  kScreenScaleFactor)


# Functions

# Graphics::load-image (String, ?Bool)
export load-image = (filename, use-transparency = no) ->
  if not spritesheets[filename]?
    spritesheets[filename] = SDL.load-image config.find-asset filename
    if use-transparency then SDL.set-color-key spritesheets[filename], kTransparentColor
    if config.kDebugMode then document.body.append-child spritesheets[filename].canvas
  return spritesheets[filename]

# Graphics::blit-surface (SDL::Surface, SDL::Rect, SDL::Rect)
export blit-surface = (source, src-rect, dest-rect) ->
  SDL.blit-surface source, src-rect, screen, dest-rect

# Graphics::visualiseRect (Rect)
export visualiseRect = (rect, fill) ->

  # translate between game Rect and SDL Rect
  paint-rect = new SDL.Rect units.game-to-px(rect.left), units.game-to-px(rect.top),
    units.game-to-px(rect.w), units.game-to-px(rect.h)

  if fill
    screen.draw-rect paint-rect, \red
  else
    screen.draw-box paint-rect, \red


# Graphics::clear
export clear = ->
  screen.clear!

