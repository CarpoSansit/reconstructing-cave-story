
# Graphics Class

require! \std
require! \SDL

{ ImageAsset } = require \./asset-manager


# Reference constants

kScreenWidth  = 640
kScreenHeight = 480


# Internal state

screen = SDL.set-video-mode(kScreenWidth, kScreenHeight, SDL.FULLSCREEN)
spritesheets = {}


# Functions

export load-image = (path) ->
  if not spritesheets[path]?
    spritesheets[path] = new SDL.UnloadedSurface path, (surface) ->
      spritesheets[path] = surface
  spritesheets[path]

export blit-surface = (source, src-rect, dest-rect) ->
  SDL.blit-surface source, src-rect, screen, dest-rect

export clear = ->
  screen.clear!

