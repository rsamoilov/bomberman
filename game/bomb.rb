class Bomb < GameObject
  RADIUS = 3
  DELAY = 3

  attr_reader :player

  def initialize(player)
    @player = player
    @callbacks = []
    EM.add_timer(DELAY) { @callbacks.each { |c| c.call(self) } }
  end

  def when_exploded(&block)
    @callbacks << block
  end

  def inspect
    "#<#{self.class.name}:#{self.object_id}>"
  end
end
