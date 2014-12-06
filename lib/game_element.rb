class GameElement

  attr_accessor :x, :y, :char, :color, :con, :game_map, :map, :fov_map

  def initialize(startx, starty, character, char_color, console, map, fov_recompute_on_move = false)
    @x = startx
    @y = starty
    @char = character
    @color = char_color
    @con = console
    @map = map
    @game_map = map.game_map
    @fov_map = map.fov_map

    @fov_recompute_on_move = fov_recompute_on_move
  end

  def move(dx, dy)
    unless @game_map[x + dx][y + dy].blocked
      @x += dx
      @y += dy
      @map.fov_recompute(player: self) if @fov_recompute_on_move
    end
  end

  def draw
    if TCOD.map_is_in_fov(@fov_map, x, y)
      TCOD.console_set_default_foreground(con, color)
      TCOD.console_put_char(@con, x, y, @char.ord, TCOD::BKGND_NONE)
    end
  end

  def clear
    TCOD.console_put_char_ex(con, x, y, '.'.ord, TCOD::Color::WHITE, TCOD::Color::BLACK)
  end

end
