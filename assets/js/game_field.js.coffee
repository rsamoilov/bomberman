class @GameField
  constructor: ->
    @containerId = "#game_field"
    @setupConnection()

  setupConnection: ->
    uri = "wss://#{window.document.location.host}/"
    @ws = new WebSocket(uri)

    @ws.onmessage = (message) =>
      dataArr = JSON.parse(message.data)

      dataArr.forEach (data) =>
        if (fieldData = data['field'])?
          @processGameField(fieldData)
        else if (updateData = data['update_game_field'])?
          @processGameFieldUpdated(updateData)
        else if (updateData = data['bomb_exploded'])?
          @processBombExploded(updateData)
        else if (bombsCount = data['available_bombs_count'])?
          @processBombsCount(bombsCount)
        else if (updateData = data['killed'])?
          @processPlayerKilled(updateData)
        else if data['won']?
          @processPlayerWon()

  # draw game field
  processGameField: (gameFieldData) ->
    cellSize = 50
    fieldHeight = gameFieldData.length
    fieldWidth = gameFieldData[0].length
    @fieldHeight = fieldHeight
    @fieldWidth = fieldWidth

    @players = {}

    # create svg
    svg = d3.select(@containerId).
             append("svg").
             attr("width", "100%").
             attr("height", cellSize * fieldHeight)

    # create rows
    g = svg.selectAll("g").
            data(gameFieldData).
            enter().
            append("g").
            attr("transform", (d, i) -> "translate(0, #{i * cellSize})")

    # create cells
    g.selectAll("rect").
      data((d) -> d).
      enter().
      append("rect").
      attr('class', 'cell').
      attr("width", cellSize).
      attr("height", cellSize).
      attr("x", (d, i) -> i * cellSize)

    # create text elements for each cell
    linesNo = -1
    addPlayer = (playerId, elementId) => @players[playerId] = elementId

    g.selectAll("text").
      data((d) -> d).
      enter().
      append('text').
      attr('class', 'cell-text').
      attr('x', (d, i) -> i * cellSize + cellSize / 2).
      attr("y", cellSize / 2).
      attr('id', (d, i) =>
        linesNo += 1 if i == 0
        @cellId([linesNo, i])
      ).
      html((d) ->
        switch d['object']
          when 'EmptyBlock' then ''
          when 'SoftBlock'  then 'BS'
          when 'HardBlock'  then 'B'
          else
            addPlayer(d['id'], @.id)
            d['object']
      )

  processGameFieldUpdated: (updateData) ->
    [gameObject, newPosition] = [updateData['game_object'], updateData['new_position']]
    [objectId, objectName] = [gameObject['id'], gameObject['object']]

    if oldCellId = @players[objectId]
      oldCell = d3.select("##{oldCellId}")
      oldCell.html('') if oldCell.html() == objectName

    newCellId = @cellId(newPosition)
    @players[objectId] = newCellId

    newCell = d3.select("##{newCellId}")
    newCell.html(objectName)
    newCell.style('stroke', 'red') if objectName == 'Bomb'

  processBombExploded: (updateData) ->
    updateData.forEach (coords) =>
      d3.select("##{@cellId(coords)}").html('BAM').style('stroke', 'black')

    setTimeout (=>
      updateData.forEach (coords) =>
        cell = d3.select("##{@cellId(coords)}")
        cell.html('') if cell.html() == 'BAM'
        cell.style('stroke', '')
    ), 1000

  processBombsCount: (bombsCount) ->
    d3.select('#bombs_count').html(bombsCount)

  processPlayerKilled: (updateData) ->
    player = updateData['player']

    if player['object'] == 'Bot'
      cellId = @players[player['id']]
      d3.select("##{cellId}").html('')
    else if player['object'] == 'Player'
      @ws.close()
      alert 'You were killed!'

  processPlayerWon: ->
    @ws.close()
    alert 'You won!'

  playerStartsGame: ->
    @ws.send(JSON.stringify({ start: true }))

  playerGoesUp: ->
    @ws.send(JSON.stringify({ move: 'up' }))

  playerGoesDown: ->
    @ws.send(JSON.stringify({ move: 'down' }))

  playerGoesLeft: ->
    @ws.send(JSON.stringify({ move: 'left' }))

  playerGoesRight: ->
    @ws.send(JSON.stringify({ move: 'right' }))

  playerPlantsBomb: ->
    @ws.send(JSON.stringify({ bomb: true }))

  cellId: (position) ->
    "cell-#{position[0]}-#{position[1]}"
