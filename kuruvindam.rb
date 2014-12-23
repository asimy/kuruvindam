#!/usr/bin/env ruby
require 'libtcod'
require 'singleton'
require_relative 'lib/game_element'
require_relative 'lib/game_map'
require_relative 'lib/combatant'
require_relative 'lib/basic_monster'
require 'byebug'

class Kuruvindam
  include Singleton

  attr_reader :con, :elements, :player, :game_map
  attr_accessor :game_state, :player_action

  #actual size of the window
  SCREEN_WIDTH = 80
  SCREEN_HEIGHT = 50

  MAP_WIDTH = 80
  MAP_HEIGHT = 45

  LIMIT_FPS = 20  #20 frames-per-second maximum

  MAX_ROOM_MONSTERS = 3

  def initialize(width = SCREEN_WIDTH, height = SCREEN_HEIGHT)
    TCOD.console_set_custom_font('arial10x10.png', TCOD::FONT_TYPE_GREYSCALE | TCOD::FONT_LAYOUT_TCOD, 0, 0)
    TCOD.console_init_root(SCREEN_WIDTH, SCREEN_HEIGHT, 'ruby/TCOD tutorial', false, TCOD::RENDERER_SDL)
    @con = TCOD.console_new(SCREEN_WIDTH, SCREEN_HEIGHT)
    TCOD.sys_set_fps(LIMIT_FPS)

    @map = GameMap.new(MAP_WIDTH, MAP_HEIGHT)
    @game_map = @map.game_map
    @fov_map = @map.fov_map

    player_combatant = Combatant.new(hp: 30, defense: 2, power: 5, death_function: method(:player_death))
    @player = GameElement.new(@map.starting_x, @map.starting_y, '@', 'Waldo the Wanderer', TCOD::Color::GREEN, @con, @fov_map, true, player_combatant)
    @map.fov_recompute(player: @player)
    @elements = [@player]

    @map.rooms.each do |room|
      place_objects(room)
    end

    @game_state = :playing
    @player_action = nil

    game_loop
  end

  def blocked?(x, y)
    return @game_map[x][y].blocked if @game_map[x][y].blocked
    blocking_elements = elements.select {|element| element.blocks &&
                                                   element.x == x &&
                                                   element.y == y }
    return blocking_elements.size > 0
  end

  private

  def player_death(player)
    puts "#{player.name} died!"
    @game_state = :dead
    player.char = '%'
    player.color = TCOD::Color::DARK_RED
  end

  def monster_death(monster)
    puts "#{monster.name.capitalize} is dead!"
    monster.char = '%'
    monster.color = TCOD::Color::DARK_RED
    send_to_back(monster)
    monster.blocks = false
    monster.combatant = nil
    monster.ai = nil
    monster.name = "remains of #{monster.name}"
  end

  def place_objects(room)
    (0..rand(MAX_ROOM_MONSTERS)).each do
      x = rand(room.x1..room.x2)
      y = rand(room.y1..room.y2)

      if rand(1..10) <= 8
        monster_combatant = Combatant.new(hp: 10, defense: 0, power: 3, death_function: method(:monster_death))
        ai_component = BasicMonster.new(player: player)
        monster = GameElement.new(x, y, 'o', 'Orc', TCOD::Color::DESATURATED_GREEN, @con, @fov_map, true, monster_combatant, ai_component)
      else
        monster_combatant = Combatant.new(hp: 16, defense: 1, power: 4, death_function: method(:monster_death))
        ai_component = BasicMonster.new(player: player)
        monster = GameElement.new(x, y, 'T', 'Troll', TCOD::Color::DARKER_GREEN, @con, @fov_map, true, monster_combatant, ai_component)
      end
      monster.game = self

      @elements << monster
    end
  end

  def send_to_back(element)
    elements.unshift(elements.delete(element))
  end

  def player_move_or_attack(dx, dy)
    x = player.x + dx
    y = player.y + dy

    target = @elements.select {|element| element.combatant && element.x == x && element.y == y}.first

    if target
      player.combatant.attack(target)
    else
      unless blocked?(x, y)
        player.move(dx, dy)
        @map.fov_recompute(player: player)
      end
    end
  end

  def handle_keys
    #key = TCOD.console_check_for_keypress()  #real-time
    key = TCOD.console_wait_for_keypress(true)  #turn-based

    if key.vk == TCOD::KEY_ENTER && key.lalt
      #Alt+Enter: toggle fullscreen
      TCOD.console_set_fullscreen(!TCOD.console_is_fullscreen())
    elsif key.vk == TCOD::KEY_ESCAPE
      return :exit  #exit game
    end

    if @game_state == :playing
      #movement keys
      if TCOD.console_is_key_pressed(TCOD::KEY_UP)
        player_move_or_attack(0, -1)
      elsif TCOD.console_is_key_pressed(TCOD::KEY_DOWN)
        player_move_or_attack(0, 1)
      elsif TCOD.console_is_key_pressed(TCOD::KEY_LEFT)
        player_move_or_attack(-1, 0)
      elsif TCOD.console_is_key_pressed(TCOD::KEY_RIGHT)
        player_move_or_attack(1, 0)
      else
        return :didnt_take_turn
      end
    end
  end

  def render_all

    (0...MAP_HEIGHT).each do |y|
      (0...MAP_WIDTH).each do |x|
        visible = TCOD.map_is_in_fov(@map.fov_map, x, y)
        wall = @game_map[x][y].block_sight

        if visible
          if wall
            TCOD.console_put_char_ex(@con, x, y, '#'.ord, @map.color_light_wall, @map.color_light_ground)
          else
            TCOD.console_put_char_ex(@con, x, y, '.'.ord, @map.color_light_wall, @map.color_light_ground)
          end
        else
          if @game_map[x][y].explored
            if wall
              TCOD.console_put_char_ex(@con, x, y, '#'.ord, @map.color_dark_wall, @map.color_dark_ground)
            else
              TCOD.console_put_char_ex(@con, x, y, '.'.ord, @map.color_dark_wall, @map.color_dark_ground)
            end
          end
        end
      end
    end

    @elements.each {|element| element.draw unless element == player }
    player.draw
    TCOD.console_blit(con, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, nil, 0, 0, 1.0, 1.0)

    TCOD.console_set_default_foreground(con, TCOD::Color::WHITE)
    TCOD.console_print_ex(con, 1, SCREEN_HEIGHT - 2, TCOD::BKGND_NONE, TCOD::LEFT, "HP: #{player.combatant.hp}/#{player.combatant.max_hp}")
  end

  #############################################
  # Initialization & Main Loop
  #############################################
  def game_loop
    until TCOD.console_is_window_closed
      TCOD.console_set_default_foreground(con, TCOD::Color::WHITE)

      render_all

      TCOD.console_flush()
      @elements.each {|obj| obj.clear }

      #handle keys and exit game if needed
      player_action = handle_keys
      break if player_action == :exit

      if game_state == :playing && player_action != :didnt_take_turn
        elements.each do |element|
          element.ai.take_turn if element.ai
        end
      end
    end
  end

end

Kuruvindam.instance