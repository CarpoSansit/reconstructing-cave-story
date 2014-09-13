
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
kScreenScaleFactor = 2


# State

spritesheets = {}

screen = SDL.set-video-mode(
  units.tile-to-px(kScreenWidth),
  units.tile-to-px(kScreenHeight),
  kScreenScaleFactor)


# Functions

# Graphics::load-image (String, ?Bool)
export load-image = (path, use-transparency = no) ->
  if not spritesheets[path]?
    spritesheets[path] = SDL.load-image path
    if use-transparency then SDL.set-color-key spritesheets[path], kTransparentColor
    if config.kDebugMode then document.body.append-child spritesheets[path].canvas
  return spritesheets[path]

# Graphics::blit-surface (SDL::Surface, SDL::Rect, SDL::Rect)
export blit-surface = (source, src-rect, dest-rect) ->
  SDL.blit-surface source, src-rect, screen, dest-rect

# Graphics::clear
export clear = ->
  screen.clear!

