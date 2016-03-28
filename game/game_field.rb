# 
# encapsulates game field as a matrix
# 
class GameField
  DIMENSIONS = [13, 11]

  attr_reader :field

  def initialize
    @positions = {}
    init_game_field
  end

  def height
    DIMENSIONS[0]
  end

  def width
    DIMENSIONS[1]
  end

  def include?(i, j)
    i >= 0 && i < self.height && j >= 0 && j < self.width
  end

  def position(game_object)
    @positions[game_object]
  end

  def at(i, j)
    @field[i][j]
  end

  def add(game_object, i, j)
    @field[i][j] = game_object
    @positions[game_object] = [i, j]
  end

  def move(player, new_i, new_j)
    return unless self.include?(new_i, new_j)

    if @field[new_i][new_j] == @empty_block
      old_i, old_j         = @positions[player]
      @field[old_i][old_j] = @empty_block if @field[old_i][old_j] == player # it could be bomb here
      @field[new_i][new_j] = player
      @positions[player]   = [new_i, new_j]

      player
    else
      @field[new_i][new_j]
    end
  end

  def remove(game_object)
    i, j = @positions[game_object]
    @field[i][j] = @empty_block
    @positions.delete(game_object) unless game_object.instance_of?(Player)
  end

  def destroy(i, j)
    @field[i][j] = @empty_block
  end

  def bots
    @positions.select { |player, _| player.is_a?(Bot) }
  end

  def neighbors(i, j, radius: 1, include_self: false)
    neighbors = []

    left  = (1..radius).map { |time| [i, j - time, @field[i][j - time]] if self.include?(i, j - time) }.compact
    right = (1..radius).map { |time| [i, j + time, @field[i][j + time]] if self.include?(i, j + time) }.compact
    up    = (1..radius).map { |time| [i - time, j, @field[i - time][j]] if self.include?(i - time, j) }.compact
    down  = (1..radius).map { |time| [i + time, j, @field[i + time][j]] if self.include?(i + time, j) }.compact

    neighbors << [[i, j, @field[i][j]]] if include_self
    neighbors << left                   if left.any?
    neighbors << right                  if right.any?
    neighbors << up                     if up.any?
    neighbors << down                   if down.any?

    neighbors
  end

  def inspect
    "#<#{self.class.name}:#{self.object_id}>"
  end

  private

  def init_game_field
    @soft_block, @hard_block, @empty_block = SoftBlock.new, HardBlock.new, EmptyBlock.new

    @field = Array.new(self.height)
    @field.each_index { |i| @field[i] = Array.new(self.width, @empty_block) }

    (0...self.height).each do |i|
      (0...self.width).each do |j|
        if i.odd? && j.odd?
          @field[i][j] = @hard_block
        elsif j > 1 && j < self.width - 1 && rand(100) > 70
          @field[i][j] = @soft_block
        end
      end #(0...self.width).each
    end # (0...self.height).each
  end
end
