class Bot < Player
  SPEED = 1.0 / 2 # 2 cells in 1 second

  def initialize(game)
    super
    @game_field = game.field
    @last_move = nil
  end

  def start
    super
    @move_timer = EM::PeriodicTimer.new(SPEED) { make_a_move }
  end

  def kill
    super
    @move_timer.cancel
  end

  # bot controls his own speed
  def moving!
  end
  def moving?
  end

  def inspect
    "#<#{self.class.name}:#{self.object_id}>"
  end

  private

  def make_a_move
    available_directions = []
    stop_searching = false
    current_i, current_j = @game_field.position(self)

    @game_field.neighbors(current_i, current_j, radius: 1).each do |line|
      line.each do |i, j, cell|
        direction = [i - current_i, j - current_j]

        if cell.is_a?(EmptyBlock)
          available_directions << [direction, score(i, j, direction)]
        elsif cell.is_a?(Player)
          available_directions = [[direction, 1]]
          stop_searching = true
          break
        elsif cell.is_a?(SoftBlock) && rand(100) > 50
          @game.plant_bomb(self.id)
        end
      end

      break if stop_searching
    end

    direction, score = available_directions.max_by { |direction, score| score }
    return unless direction

    @last_move = direction
    @game.goto(self.id, direction[0], direction[1])
  end

  def opposite(direction)
    direction && [direction[0] * -1, direction[1] * -1]
  end

  def score(i, j, direction)
    player_position = @game_field.position(@game.player)

    score = (player_position[0] - i).abs + (player_position[1] - j).abs

    score += 10 if @game_field.at(i, j).is_a?(Bomb)
    score += 10 if direction == opposite(@last_move)

    1.0 / score
  end
end
