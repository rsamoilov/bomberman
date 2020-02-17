class Player < GameObject
  SPEED = 1.0 / 4 # 4 cells in 1 second

  def initialize(game)
    @game = game
  end

  def start
    change_bombs_available(1)
    @bombs_timer = EM::PeriodicTimer.new(10) { change_bombs_available(1) }
  end

  def kill
    @bombs_timer.cancel
  end

  def has_bombs?
    @bombs_available > 0
  end

  def create_bomb
    return unless self.has_bombs?

    bomb = Bomb.new(self)
    change_bombs_available(-1)
    bomb.when_exploded { change_bombs_available(1) }

    bomb
  end

  # limit player's speed
  def moving!
    @is_moving = true
    EM.add_timer(SPEED) { @is_moving = false }
  end

  def moving?
    @is_moving
  end

  private

  def change_bombs_available(count)
    @bombs_available ||= 0
    @bombs_available += count

    @game.updater.send_available_bombs_count self, @bombs_available
  end
end
