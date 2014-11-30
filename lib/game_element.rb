class GameElement
  
  attr_accessor(:x, :y, :char, :color, :con, :map)
  
  def initialize(startx, starty, character, char_color, console, game_map)
    @x = startx
    @y = starty
    @char = character
    @color = char_color
    @con = console
    @map = game_map
  end
  
  def move(dx, dy)
    unless map[x + dx][y + dy].blocked
      @x += dx
      @y += dy
    end
  end
  
  def draw
    TCOD.console_set_default_foreground(@con, color)
    TCOD.console_put_char(@con, @x, @y, @char.ord, TCOD::BKGND_NONE)
  end
  
  def clear
    TCOD.console_put_char_ex(@con, @x, @y, '.'.ord, TCOD::Color::WHITE, TCOD::Color::BLACK)
  end
  
end
