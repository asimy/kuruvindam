class GameMap
  
  attr_reader :game_map
  
  def initialize(width, height)
    @width = width
    @height = height
    
    make_game_map
  end

  def make_game_map
    @game_map = Array.new(@width) { Array.new(@height) { Tile.new(false) } }
    
    game_map[30][22].blocked = true
    game_map[30][22].block_sight = true
    game_map[50][22].blocked = true
    game_map[50][22].block_sight = true
  end
end

class Tile
  
  attr_accessor :blocked, :block_sight
  
  def initialize(blocked, block_sight = nil)
    @blocked = blocked
    
    @block_sight = block_sight.nil? ? @blocked : block_sight
  end
end