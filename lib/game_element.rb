class GameElement

  attr_accessor :x, :y, :char, :color, :con, :fov_map, :name, :blocks, :combatant, :ai, :game, :inventory

  def initialize(startx, starty, character, name, char_color, console, fov_map, blocks: false, combatant: nil, ai: nil, inventory: [])
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

    @inventory = Array(inventory) || []
    take_ownership(@inventory)

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

  def take_ownership(inventory)
    inventory.each do |item|
      item.owner = self
    end
  end

  def pick_up(target)
    if @inventory.size >= 26
      game.message("Your inventory is full. You can not pick up anything from #{target.name}.", TCOD::Color::RED)
    elsif @inventory.size >= 26 - target.inventory.size
      game.message("You don't have enough room to pick up everything from #{target.name}.", TCOD::Color::RED)
      # need dialog allowing player to choose what to pick up
    else
      game.message("You found #{target.inventory.map(&:name).join(',')}.", TCOD::Color::RED)
      @inventory += target.inventory
      take_ownership(@inventory)
      game.elements.delete(target)
    end
  end
end
