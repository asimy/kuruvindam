class GameElement
  
  attr_accessor(:x, :y, :char, :color, :con)
  
  def initialize(startx, starty, character, char_color, console)
    @x = startx
    @y = starty
    @char = character
    @color = char_color
    @con = console
  end
  
  def move(dx, dy)
    @x += dx
    @y += dy
  end
  
  def draw
    TCOD.console_set_default_foreground(@con, color)
    TCOD.console_put_char(@con, @x, @y, @char.ord, TCOD::BKGND_NONE)
  end
  
  def clear
    TCOD.console_put_char(@con, @x, @y, ' '.ord, TCOD::BKGND_NONE)
  end
  
end
