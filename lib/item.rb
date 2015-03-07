require_relative 'message_manager'

class Item

  attr_reader :name, :character, :color
  attr_accessor :owner, :old_owner

  def initialize(name, character, color, effect = nil)
    @name = name
    @use_function = effect
    @character = character
    @color = color

    @message_manager = MessageManager.instance
  end

  def use_item
    if @use_function.nil?
      message("The #{name} cannot be used.", TCOD::Color::WHITE)
    else
      if @use_function.call != 'cancelled'
        owner.inventory.delete(self)
      end
    end
  end

  def drop
    owner.drop(self)
  end

  def message(new_msg, color = TCOD::Color::WHITE)
    @message_manager.message(new_msg, color)
  end
end