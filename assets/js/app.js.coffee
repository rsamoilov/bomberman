#= require d3
#= require game_field

gameField = new GameField()

keys = {}

document.onkeydown = (e) ->
  keys[e.keyCode] = true

document.onkeyup = (e) ->
  keys[e.keyCode] = false

gameLoop = ->
  if keys[83] then gameField.playerStartsGame()
  if keys[66] then gameField.playerPlantsBomb()

  if keys[37] then gameField.playerGoesLeft()
  if keys[38] then gameField.playerGoesUp()
  if keys[39] then gameField.playerGoesRight()
  if keys[40] then gameField.playerGoesDown()

setInterval gameLoop, 50
