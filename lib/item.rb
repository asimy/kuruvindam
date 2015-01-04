require_relative 'component_messaging'

class Item
  include ComponentMessaging

  attr_reader :name
  attr_accessor :owner

  def initialize(name, effect = nil)
    @name = name
    @use_function = effect
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
end