
# Reconstructing Cave Story (RCS)
# Main program file

# Require

Game   = require \./game
Assets = require \./asset-manager


# Load resources we need

Assets.set-cwd 'content'
Assets.add-resources do
  MyChar: 'MyChar.bmp'
  bkBlue: 'bkBlue.bmp'
  PrtCave: 'PrtCave.bmp'


# When ready, start game

Assets.on-all-available (assets) ->
  Game.start assets: assets

