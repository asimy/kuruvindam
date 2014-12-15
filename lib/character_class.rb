class CharacterClass

  attr_accessor :max_hp, :hp, :defense, :power, :owner

  def initialize(hp:, defense:, power:)
    @max_hp = hp
    @hp = hp
    @defense = defense
    @power = power
  end

end