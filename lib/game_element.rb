class GameElement

  attr_accessor :x, :y, :char, :color, :con, :fov_map

  def initialize(startx, starty, character, char_color, console, fov_map)
    @x = startx
    @y = starty
    @char = character
    @color = char_color
    @con = console
    @fov_map = fov_map
  end

  def move(dx, dy)
      @x += dx
      @y += dy
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
