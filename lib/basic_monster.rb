class BasicMonster

  attr_reader :player
  attr_accessor :owner

  def initialize(player:)
    @owner = owner
    @player = player
  end

  def take_turn
    monster = owner
    if TCOD.map_is_in_fov(owner.fov_map, monster.x, monster.y)
      if monster.distance_to(player) > 2
        monster.move_towards(player.x, player.y)
      elsif player.char_class.hp > 0
        puts "The attack of the #{monster.name} bounces off of you shiny metal a--, uh, armor!"
      end
    end
  end
end