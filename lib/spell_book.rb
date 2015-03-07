require_relative 'message_manager'

module SpellBook
  HEAL_AMOUNT = 4

  LIGHTNING_RANGE = 5
  LIGHTNING_DAMAGE = 20

  FIREBALL_RADIUS = 3
  FIREBALL_DAMAGE = 8

  CONFUSE_RANGE = 8

  @message_mananger = MessageManager.instance

  def message(new_msg, color = TCOD::Color::WHITE)
    @message_manager.message(new_msg, color)
  end

  def heal_player
    -> do
      if player.combatant.hp == player.combatant.max_hp
        message('You are already at full health.', TCOD::Color::LIGHT_BLUE)
        return 'cancelled'
      end

      message('Your wounds start to feel better!', TCOD::Color::LIGHT_VIOLET)
      player.combatant.heal(HEAL_AMOUNT)
    end
  end

  def lightning_bolt
    -> do
      monster = closest_monster(LIGHTNING_RANGE)
      if monster.nil?  # no enemy found within maximum range;
        message('No enemy is close enough to strike.', TCOD::Color::LIGHT_BLUE)
        return 'cancelled'
      end

      # zap it!
      message("A lighting bolt strikes the #{monster.name} with a loud thunder! The damage is #{LIGHTNING_DAMAGE} hit points.", TCOD::Color::LIGHT_BLUE)
      monster.combatant.take_damage(LIGHTNING_DAMAGE)
    end
  end

  def confuse_monster
    -> do
      message('Left-click a target monster to confuse, or right-click to cancel.', TCOD::Color::LIGHT_CYAN)
      monster = target_monster(CONFUSE_RANGE)
      return 'cancelled' unless monster

      # puzzle it!
      old_ai = monster.ai
      monster.ai = ConfusedMonster.new(old_ai)
      monster.ai.owner = monster
      message("A look of puzzlement crosses the face of the #{monster.name}.", TCOD::Color::LIGHT_BLUE)
    end
  end

  def fireball
    -> do
      # ask the player for a target tile to throw a fireball at
      message('Left-click a target tile for the fireball, or right-click to cancel.', TCOD::Color::LIGHT_CYAN)
      x, y = target_tile
      return 'cancelled' unless x
      message("The fireball explodes, burning everything within #{FIREBALL_RADIUS} tiles!", TCOD::Color::ORANGE)

      elements.each do |element|  # damage every fighter in range, including the player
        if element.distance(x, y) <= FIREBALL_RADIUS && element.combatant
          message("The #{element.name} gets burned for #{FIREBALL_DAMAGE} hit points.", TCOD::Color::ORANGE)
          element.combatant.take_damage(FIREBALL_DAMAGE)
        end
      end
    end
  end
end
