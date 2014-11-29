require_relative 'rubylike'

class GameElement
  
  attr_accessor :x, :y, :char, :color, :con
  
  def initialize(x, y, char, color)
    @x = x
    @y = y
    @char = char
    @color = color
    @con = Rubylike.instance.con
  end
  
  def move(dx, dy)
    x += dx
    y += dy
  end
  
  def draw
    TCOD.console_set_default_foreground(con, color)
    TCOD.console_put_char(con, x, y, char, TCOD.BKGND_NONE)
  end
  
  def clear
    TCOD.console_put_char(con, x, y, ' ', TCOD.BKGND_NONE)
  end
  
end