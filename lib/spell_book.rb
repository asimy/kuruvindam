module SpellBook
  HEAL_AMOUNT = 4

  LIGHTNING_RANGE = 5
  LIGHTNING_DAMAGE = 20

  def heal_player
    -> {
      if player.combatant.hp == player.combatant.max_hp
        message('You are already at full health.', TCOD::Color::LIGHT_BLUE)
        return 'cancelled'
      end

      message('Your wounds start to feel better!', TCOD::Color::LIGHT_VIOLET)
      player.combatant.heal(HEAL_AMOUNT)
    }
  end

  def lightning_bolt
    -> { monster = closest_monster(LIGHTNING_RANGE)
      if monster.nil?  #no enemy found within maximum range;
        message('No enemy is close enough to strike.', TCOD::Color::LIGHT_BLUE)
        return 'cancelled'
      end

      # zap it!
      message("A lighting bolt strikes the #{monster.name} with a loud thunder! The damage is #{LIGHTNING_DAMAGE} hit points.", TCOD::Color::LIGHT_BLUE)
      monster.combatant.take_damage(LIGHTNING_DAMAGE)
    }
  end

  def confuse_monster
    -> {
      monster = closest_monster(LIGHTNING_RANGE)
      if monster.nil?  #no enemy found within maximum range
        message('No enemy is close enough to strike.', TCOD::Color::LIGHT_BLUE)
        return 'cancelled'
      end

      # zap it!
      old_ai = monster.ai
      monster.ai = ConfusedMonster.new(old_ai)
      monster.ai.owner = monster
      message("A look of puzzlement crosses the face of the #{monster.name}.", TCOD::Color::LIGHT_BLUE)
    }
  end
end