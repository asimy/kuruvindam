class GameElement

  attr_accessor :x, :y, :char, :color, :con, :fov_map, :name, :blocks, :combatant, :ai, :game

  def initialize(startx, starty, character, name, char_color, console, fov_map, blocks = false, combatant = nil, ai = nil)
    @x = startx
    @y = starty
    @char = character
    @color = char_color
    @con = console
    @fov_map = fov_map
    @name = name
    @blocks = blocks
    @combatant = combatant
    combatant.owner = self if combatant

    @ai = ai
    ai.owner = self if ai
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
    if TCOD.map_is_in_fov(@fov_map, x, y)
      TCOD.console_put_char(con, x, y, '.'.ord, TCOD::BKGND_NONE)
    end
  end

  def move_towards(target_x, target_y)
    dx = target_x - x
    dy = target_y - y

    distance = Math.sqrt(dx ** 2 + dy ** 2)

    dx = (dx/distance).round.to_i
    dy = (dy/distance).round.to_i
    move(dx, dy) unless game.blocked?(x + dx, y + dy)
  end

  def distance_to(other_element)
    dx = other_element.x - x
    dy = other_element.y - y
    Math.sqrt(dx ** 2 + dy ** 2)
  end

end
