class MovementManager
  attr_accessor :elements, :fov_map
  attr_reader :game_map, :map

  def initialize(map_object)
    @map = map_object
    @game_map = @map.game_map
    @fov_map = @map.fov_map
  end

  def blocked?(x, y)
    return game_map[x][y].blocked if game_map[x][y].blocked
    blocking_elements = elements.select do|element|
      element.blocks &&
      element.x == x &&
      element.y == y
    end
    blocking_elements.size > 0
  end
end
