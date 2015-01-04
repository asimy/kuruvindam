require_relative 'component_messaging'

class ConfusedMonster
  include ComponentMessaging

  CONFUSE_NUM_TURNS = 10

  attr_accessor :owner
  attr_reader :old_ai, :duration

  def initialize(old_ai, duration=CONFUSE_NUM_TURNS)
    @old_ai = old_ai
    @duration = duration
  end

  def take_turn
    monster = owner
    if @duration > 0
      monster.move(rand(-1..1), rand(-1..1))
      @duration -= 1
    else
      monster.ai = @old_ai
      message("The #{monster.name} is no longer confused!", TCOD::Color::WHITE)
    end
  end
end