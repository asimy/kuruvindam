class Item

  attr_reader :name
  attr_accessor :owner

  def initialize(name, &block)
    @name = name
    @use_function = block
  end

  def use_item
    if @use_function.nil?
      puts "The #{name} cannot be used"
    else
      if @use_function.call != 'cancelled'
        owner.inventory.delete(self)
      end
    end
  end

end