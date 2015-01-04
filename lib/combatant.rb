require_relative 'component_messaging'

class Combatant
  include ComponentMessaging

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
      message("#{owner.name} attacks #{target.name} for #{damage} hit points", TCOD::Color::YELLOW)
      target.combatant.take_damage(damage)
    else
      message("#{owner.name.captalize} attacks #{target.name} but it has no effect!", TCOD::Color::WHITE)
    end
  end

  def heal(heal_amount)
    @hp += heal_amount

    @hp = [@hp, @max_hp].min
  end
end