class GameMap

  ROOM_MAX_SIZE = 10
  ROOM_MIN_SIZE = 6
  MAX_ROOMS = 30

  FOV_ALGORITHM = 0
  FOV_LIGHT_WALLS = true
  TORCH_RADIUS = 10

  attr_reader :game_map, :fov_map, :starting_x, :starting_y
  attr_accessor :color_dark_wall, :color_light_wall, :color_dark_ground, :color_light_ground

  def initialize(width, height)
    @width = width
    @height = height

    @rooms = []

    color_dark_wall    = TCOD.color_RGB(0, 0, 100)
    color_light_wall   = TCOD.color_RGB(130, 110, 50)
    color_dark_ground  = TCOD.color_RGB(50, 50, 150)
    color_light_ground = TCOD.color_RGB(200, 180, 50)

    @fov_map = TCOD.map_new(@width, @height)


    make_game_map
    setup_fov_map
  end

  def make_game_map
    @game_map = Array.new(@width) { Array.new(@height) { Tile.new(true) } }

    (1..MAX_ROOMS).each_with_index do |i|
      w = rand(ROOM_MIN_SIZE..ROOM_MAX_SIZE)
      h = rand(ROOM_MIN_SIZE..ROOM_MAX_SIZE)
      x = rand(0...(@width - w - 1))
      y = rand(0...(@height - h - 1))

      new_room = Rect.new(x, y, w, h)

      succeeded = true
      @rooms.each do |room|
        if new_room.intersect(room)
          succeeded = false
          break
        end
      end

      if succeeded
        create_room(new_room)
        new_x, new_y = new_room.center

        if @rooms.empty?
          @starting_x, @starting_y = new_x, new_y
        else
          prev_x, prev_y = @rooms[@rooms.size - 1].center

          if rand(1..2) == 1
            create_horizontal_tunnel(prev_x, new_x, prev_y)
            create_vertical_tunnel(prev_y, new_y, new_x)
          else
            create_vertical_tunnel(prev_y, new_y, prev_x)
            create_horizontal_tunnel(prev_x, new_x, new_y)
          end
        end

        @rooms << new_room
      end
    end
  end

  def setup_fov_map
    (0...@width).each do |x|
      (0...@height).each do |y|
        TCOD.map_set_properties(@fov_map, x, y, !@game_map[x][y].block_sight, !@game_map[x][y].blocked)
      end
    end
  end

  def fov_recompute(player:)
    TCOD.map_compute_fov(fov_map, player.x, player.y, TORCH_RADIUS, FOV_LIGHT_WALLS, FOV_ALGORITHM)
  end

  def create_room(room)
    (room.x1..room.x2).each do |x|
      (room.y1..room.y2).each do |y|
        game_map[x][y].blocked = false
        game_map[x][y].block_sight = false
      end
    end
  end

  def create_horizontal_tunnel(x1, x2, y)
    ([x1, x2].min..[x1,x2].max).each do |x|
      game_map[x][y].blocked = false
      game_map[x][y].block_sight = false
    end
  end

  def create_vertical_tunnel(y1, y2, x)
    ([y1, y2].min..[y1,y2].max).each do |y|
      game_map[x][y].blocked = false
      game_map[x][y].block_sight = false
    end
  end
end

class Tile

  attr_accessor :blocked, :block_sight

  def initialize(blocked, block_sight = nil)
    @blocked = blocked

    @block_sight = block_sight.nil? ? @blocked : block_sight
  end
end

class Rect

  attr_reader :x1, :x2, :y1, :y2

  def initialize(top_left_x, top_left_y, width, height)
    @x1 = top_left_x
    @y1 = top_left_y
    @x2 = top_left_x + width
    @y2 = top_left_y + height
  end

  def center
    center_x = (x1 + x2)/2
    center_y = (y1 + y2)/2
    return center_x, center_y
  end

  def intersect(other_rectangle)
    x1 <= other_rectangle.x2 && x2 >= other_rectangle.x1 &&
    y1 <= other_rectangle.y2 && y2 >= other_rectangle.y1
  end
end