require_relative 'message_manager'

class Item

  attr_reader :name
  attr_accessor :owner, :old_owner

  def initialize(name, effect = nil)
    @name = name
    @use_function = effect

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
    byebug
    self.owner.game.elements << old_owner
    old_inventory = owner.inventory
    @owner = old_owner
    old_inventory.delete(self)
  end

  def message(new_msg, color = TCOD::Color::WHITE)
    @message_manager.message(new_msg, color)
  end
end