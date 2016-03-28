#
# base class for all the game objects to inherit from
#
class GameObject
  def name
    self.class.name
  end

  def id
    self.object_id
  end

  def start
  end

  def kill
  end

  def to_h
    { object: self.name, id: self.id }
  end

  def to_json(*args)
    to_h.to_json(*args)
  end
end
