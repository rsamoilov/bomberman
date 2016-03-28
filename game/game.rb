# 
# main game class
# generates game field, simulates the game and sends updates to ui
# 
class Game
  attr_reader :field, :player, :updater

  def initialize(updater = StubUpdater.new(nil))
    @updater = updater

    @field = GameField.new
    @updater.send_field(@field)

    init_players
  end

  def start
    unless @started
      @started = true
      @players.each_value { |player| player.start }
    end
  end

  def stop
    if @started
      @players.each_value { |player| player.kill }
    end
  end

  def started?
    @started
  end

  def goright(player_id)
    goto(player_id, 0, 1)
  end

  def goleft(player_id)
    goto(player_id, 0, -1)
  end

  def goup(player_id)
    goto(player_id, -1, 0)
  end

  def godown(player_id)
    goto(player_id, 1, 0)
  end

  def goto(player_id, change_i, change_j)
    player = @players[player_id]
    return if player.moving?

    i, j = @field.position(player)
    new_i, new_j = i + change_i, j + change_j

    new_cell = @field.move(player, new_i, new_j)

    if new_cell.nil?
      # skip
    elsif new_cell == player
      player.moving!
      @updater.send_game_field_updated(player, [new_i, new_j])
    elsif new_cell.is_a?(Player) # player or bot
      player.moving!
      new_cell.instance_of?(Player) ? kill_player(new_cell) : kill_player(player)
    end
  end

  def plant_bomb(player_id)
    player = @players[player_id]
    position = @field.position(player)

    bomb = player.create_bomb

    if bomb
      @field.add bomb, *position
      bomb.when_exploded { |bomb| bomb_exploded(bomb) }
      @updater.send_game_field_updated(bomb, position)
    end
  end

  def inspect
    "#<#{self.class.name}:#{self.object_id}>"
  end

  private

  def init_players
    @player = Player.new(self)

    new_players = [
      [@player, [0, 0]],
      [Bot.new(self), [0, @field.width - 1]],
      [Bot.new(self), [@field.height - 1, 0]],
      [Bot.new(self), [@field.height - 1, @field.width - 1]]
    ]

    @players = {}

    new_players.each do |player, (i, j)|
      @players[player.id] = player
      @field.add player, i, j
      @updater.send_game_field_updated(player, [i, j])
    end
  end

  def bomb_exploded(bomb)
    i, j = @field.position(bomb)
    radius = bomb.class.const_get(:RADIUS) - 1

    updates = []

    if @field.position(bomb.player) == [i, j] # player remains on the bomb
      kill_player(bomb.player)
      updates << [i, j]
    end
    
    @field.neighbors(i, j, radius: radius, include_self: true).each do |line|
      line.each do |i_chk, j_chk, cell|

        if cell.is_a?(Bomb)
          @field.remove(bomb)
          updates << [i_chk, j_chk]
        elsif cell.is_a?(HardBlock)
          break
        elsif cell.is_a?(SoftBlock)
          @field.destroy(i_chk, j_chk)
          updates << [i_chk, j_chk]
          break
        elsif cell.is_a?(Player) # player or bot
          kill_player(cell)
          updates << [i_chk, j_chk]
          break
        end

      end # @field.neighbors(radius).each
    end # line.each

    @updater.send_bomb_exploded(updates)
  end

  def kill_player(player)
    player.kill
    @field.remove(player)
    @updater.send_player_killed(player)

    @updater.send_player_won if @field.bots.none?
  end
end
