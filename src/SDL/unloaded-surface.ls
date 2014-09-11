
require! \SDL


# UnloadedSurface satisfies the same interfaces as Surface, but works
# with no image data without throwing errors

module.exports = class UnloadedSurface

  (path, λ) ->
    @canvas = document.create-element \canvas
    @ctx    = @canvas.get-context \2d
    @load-data path, λ

  load-data: (path, λ) ->
    data = new Image
    data.onload = ~> @data-loaded λ, data
    data.src = path

  data-loaded: (λ, data) ->
    @ready = yes
    @data  = data
    λ? new SDL.Surface data, data.naturalWidth, data.naturalHeight

  clear: ->
  @blit-surface = ->

