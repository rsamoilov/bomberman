#
# implementation of backend-ui protocol
#
class Updater
  def initialize(websocket)
    @websocket = websocket
    @buffer = []
  end

  def send_field(game_field)
    send(field: game_field.field)
  end

  def send_available_bombs_count(player, count)
    return if player.is_a?(Bot)
    send(available_bombs_count: count)
  end

  def send_bomb_exploded(explode_coordinates)
    send(bomb_exploded: explode_coordinates)
  end

  def send_game_field_updated(game_object, new_position)
    send(update_game_field: {
      game_object: game_object,
      new_position: new_position
    })
  end

  def send_player_killed(player)
    send(killed: { player: player })
  end

  def send_player_won
    send(won: true)
  end

  private

  def send(message)
    if @buffer.empty?
      EM.next_tick do
        @websocket.send @buffer.to_json
        @buffer = []
      end
    end

    @buffer << message
  end
end
