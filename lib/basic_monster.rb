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
      elsif player.combatant.hp > 0
        monster.combatant.attack(player)
      end
    end
  end
end