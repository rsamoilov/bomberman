class EmptyBlock < GameObject
  def to_h
    { object: self.name }
  end
end
