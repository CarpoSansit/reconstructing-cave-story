
# Asset Library
#
# A library is a concept we need which isn't required in the original RCS, so
# that we can ensure the image resources we need are prepared before beginning
# the game. There may be a cool way to make the render function robust against
# missing assets and have them update live during gameplay, but let's hold off
# on that and just preload everything up front for now.

# Require

require! \std


# Internal State

path       = ""
callback   = ->
all-assets = []
library    = {}


# Asset classes

export class Asset
  (@name, src) ->
    @ready = no

  # Static
  @is-ready  = (asset) -> asset.ready
  @not-ready = (asset) -> not asset.ready


export class ImageAsset extends Asset
  (@name, src, λ = id) ->
    super ...
    @load src, λ

  load: (src, λ) ->
    data = new Image
    data.onload = ~> @on-ready λ, data
    data.src = src

  on-ready: (λ, data) ->
    @ready = yes
    @data  = data
    λ @name, this


# Functions

add-resource = (name, src) ->
  if library[name]?
    throw new Error do
      message: "AssetManager - asset with this name already exists: #name"

  asset = new ImageAsset name, "/#path/#src", register-asset-available
  all-assets.push asset

register-asset-available = (name, asset) ->
  library[name] = asset
  std.log "AssetManager::RegisterAssetAvailable -", name
  unless std.any Asset.not-ready, all-assets
    callback library


# Export

export do
  set-cwd       : -> path := it
  get-library   : -> library
  add-resource  : add-resource
  add-resources : std.obj-map add-resource
  on-all-available: -> callback := it

