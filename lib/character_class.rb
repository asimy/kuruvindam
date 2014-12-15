class CharacterClass

  attr_accessor :max_hp, :hp, :defense, :power, :owner

  def initialize(hp:, defense:, power:)
    @max_hp = hp
    @hp = hp
    @defense = defense
    @power = power
  end

  def take_damage(damage)
      @hp -= damage if damage > 0
  end

  def attack(target)
    damage = power - target.char_class.defense

    if damage > 0
      puts "#{owner.name} attacks #{target.name} for #{damage} hit points"
      target.char_class.take_damage(damage)
    else
      puts "#{owner.name.captalize} attacks #{target.name} but it has no effect!"
    end
  end
end