class Combatant

  attr_accessor :max_hp, :hp, :defense, :power, :owner, :death_function

  def initialize(hp:, defense:, power:, death_function: nil)
    @max_hp = hp
    @hp = hp
    @defense = defense
    @power = power
    @death_function = death_function
    @owner = nil
  end

  def take_damage(damage)
      @hp -= damage if damage > 0 # TODO sort out this death function stuff
      if hp <= 0 && death_function
        death_function.call(owner)
      end
  end

  def attack(target)
    damage = power - target.combatant.defense

    if damage > 0
      puts "#{owner.name} attacks #{target.name} for #{damage} hit points"
      target.combatant.take_damage(damage)
    else
      puts "#{owner.name.captalize} attacks #{target.name} but it has no effect!"
    end
  end
end