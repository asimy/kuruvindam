#!/usr/bin/env ruby
require 'libtcod'
require 'singleton'
require_relative 'lib/message_manager'
require_relative 'lib/movement_manager'
require_relative 'lib/game_element'
require_relative 'lib/game_map'
require_relative 'lib/combatant'
require_relative 'lib/basic_monster'
require_relative 'lib/confused_monster'
require_relative 'lib/item'
require_relative 'lib/spell_book'
require 'byebug'

class Kuruvindam
  include Singleton
  include SpellBook

  attr_reader :con, :panel, :player, :game_map, :mouse, :key, :movement_manager
  attr_accessor :game_state, :player_action, :game_messages

  # actual size of the window
  SCREEN_WIDTH = 80
  SCREEN_HEIGHT = 50

  MAP_WIDTH = 80
  MAP_HEIGHT = 43

  LIMIT_FPS = 20  # 20 frames-per-second maximum

  MAX_ROOM_MONSTERS = 2
  MAX_ROOM_ITEMS = 3

  # sizes and coordinates relevant for the GUI
  BAR_WIDTH = 20
  PANEL_HEIGHT = 7
  PANEL_Y = SCREEN_HEIGHT - PANEL_HEIGHT

  INVENTORY_WIDTH = 50

  MSG_X = BAR_WIDTH + 2
  MSG_WIDTH = SCREEN_WIDTH - BAR_WIDTH - 2
  MSG_HEIGHT = PANEL_HEIGHT - 1

  def initialize(width = SCREEN_WIDTH, height = SCREEN_HEIGHT)
    TCOD.console_set_custom_font('arial10x10.png', TCOD::FONT_TYPE_GREYSCALE | TCOD::FONT_LAYOUT_TCOD, 0, 0)
    TCOD.console_init_root(width, height, 'ruby/TCOD tutorial', false, TCOD::RENDERER_SDL)
    @con = TCOD.console_new(width, height)
    @panel = TCOD.console_new(width, height)

    TCOD.sys_set_fps(LIMIT_FPS)

    @mouse = TCOD::Mouse.new
    @key = TCOD::Key.new

    @movement_manager = MovementManager.new(GameMap.new(MAP_WIDTH, MAP_HEIGHT))

    player_combatant = Combatant.new(hp: 29, defense: 2, power: 5, death_function: method(:player_death))
    @player = GameElement.new(map.starting_x, map.starting_y, '@', 'Waldo the Wanderer', TCOD::Color::BLUE, @con, @movement_manager, blocks: true, combatant: player_combatant)
    map.fov_recompute(player: @player)
    movement_manager.elements = [@player]

    map.rooms.each do |room|
      place_objects(room)
    end

    @game_state = :playing
    @player_action = nil

    @message_manager = MessageManager.instance
    @game_messages = @message_manager.game_messages

    message('Welcome stranger! Prepare to perish in the Tombs of the Ancient Kings.', TCOD::Color::RED)

    game_loop
  end

  def elements
    movement_manager.elements
  end

  def blocked?(x, y)
    movement_manager.blocked?(x, y)
  end

  def map
    movement_manager.map
  end

  def game_map
    movement_manager.game_map
  end

  def fov_map
    movement_manager.fov_map
  end

  def message(new_msg, color = TCOD::Color::WHITE)
    @message_manager.message(new_msg, color)
  end

  def menu(header, entries, width)
    fail 'cannot have a menu with more than 26 entries' if entries.count >= 26

    header_height = TCOD.console_get_height_rect(con, 0, 0, width, SCREEN_HEIGHT, header)
    height = entries.count + header_height

    window = TCOD.console_new(width, height)

    TCOD.console_set_default_foreground(window, TCOD::Color::WHITE)
    TCOD.console_print_rect_ex(window, 0, 0, width, height, TCOD::BKGND_NONE, TCOD::LEFT, header)

    y = header_height
    letters = ('a'..'z').to_a

    entries.each_with_index do |entry, i|
      menu_item_text = "(#{letters[i]}) #{entry}"
      TCOD.console_print_ex(window, 0, y, TCOD::BKGND_NONE, TCOD::LEFT, menu_item_text)
      y += 1
    end

    # blit the contents of 'window' to the root console
    x = SCREEN_WIDTH / 2 - width / 2
    y = SCREEN_HEIGHT / 2 - height / 2
    TCOD.console_blit(window, 0, 0, width, height, nil, x, y, 1.0, 0.7)

    # show the root console and hold for a key press
    TCOD.console_flush
    key = TCOD.console_wait_for_keypress(true)

    key.c.ord - 'a'.ord # item index
  end

  def inventory_menu(header)
    if player.inventory.empty?
      entries = ['Inventory is empty']
    else
      entries = player.inventory.map(&:name)
    end

    index = menu(header, entries, INVENTORY_WIDTH)
    player.inventory[index]
  end

  def monsters_in_view
    elements.select { |element| element.combatant && element != player && TCOD.map_is_in_fov(fov_map, element.x, element.y) }
  end

  def closest_monster(max_range)
    nearest_monster = monsters_in_view.select { |monster| TCOD.map_is_in_fov(fov_map, monster.x, monster.y) }.sort { |a, b| player.distance_to(a) <=> player.distance_to(b) }.first
    player.distance_to(nearest_monster) <= max_range ? nearest_monster : nil
  end

  def player_death(player)
    message("#{player.name} died!", TCOD::Color::WHITE)
    @game_state = :dead
    player.char = '%'
    player.color = TCOD::Color::DARK_RED
  end

  def monster_death(monster)
    message("#{monster.name.capitalize} is dead!", TCOD::Color::WHITE)
    monster.char = '%'
    monster.color = TCOD::Color::DARK_RED
    send_to_back(monster)
    monster.blocks = false
    monster.combatant = nil
    monster.ai = nil
    monster.name = "remains of #{monster.name}"
  end

  def place_objects(room)
    place_monsters(room)
    place_items(room)
  end

  def place_monsters(room)
    (0..rand(MAX_ROOM_MONSTERS)).each do
      x = rand(room.x1 + 1..room.x2 - 1)
      y = rand(room.y1 + 1..room.y2 - 1)

      if rand(1..10) <= 8
        monster_combatant = Combatant.new(hp: 10, defense: 0, power: 3, death_function: method(:monster_death))
        ai_component = BasicMonster.new(player: player)
        monster = GameElement.new(x, y, 'o', 'Orc', TCOD::Color::DESATURATED_GREEN, @con, movement_manager, blocks: true, combatant: monster_combatant, ai: ai_component)
      else
        monster_combatant = Combatant.new(hp: 16, defense: 1, power: 4, death_function: method(:monster_death))
        ai_component = BasicMonster.new(player: player)
        monster = GameElement.new(x, y, 'T', 'Troll', TCOD::Color::DARKER_GREEN, @con, movement_manager, blocks: true, combatant: monster_combatant, ai: ai_component)
      end

      elements << monster
    end
  end

  def place_items(room)
    (0..rand(MAX_ROOM_ITEMS)).each do
      x = rand(room.x1 + 1..room.x2 - 1)
      y = rand(room.y1 + 1..room.y2 - 1)

      unless blocked?(x, y)
        die_roll = rand(1..100)
        case
        when die_roll < 70
          inventory_item = Item.new('Healing potion', '!', TCOD::Color::VIOLET, heal_player)
        when die_roll >= 70 && die_roll < 80
          inventory_item = Item.new('Scroll of fireball', '#', TCOD::Color::DARK_RED, fireball)
        when die_roll >= 80 && die_roll < 90
          inventory_item = Item.new('Scroll of lightning bolt', '#', TCOD::Color::YELLOW, lightning_bolt)
        else die_roll >= 90 && die_roll <= 100
          inventory_item = Item.new('Scroll of confuse monster', '#', TCOD::Color::GREEN, confuse_monster)
        end

        item = GameElement.new(x, y, inventory_item.character, inventory_item.name, inventory_item.color, @con, movement_manager, inventory: inventory_item)
        elements << item
        send_to_back(item)
      end
    end
  end

  def send_to_back(element)
    elements.unshift(elements.delete(element))
  end

  def player_move_or_attack(dx, dy)
    x = player.x + dx
    y = player.y + dy

    target = elements.select { |element| element.combatant && element.x == x && element.y == y }.first

    if target
      player.combatant.attack(target)
    else
      unless blocked?(x, y)
        player.move(dx, dy)
        map.fov_recompute(player: player)
      end
    end
  end

  def get_names_under_mouse
    x, y = mouse.cx, mouse.cy

    names = elements.select { |element| element.x == x &&
                                        element.y == y &&
                                        TCOD.map_is_in_fov(fov_map, element.x, element.y) }
            .map { |element|  element.owner ? "#{element.name} owned by #{element.owner}" : element.name }

    names.map(&:capitalize).join(', ')
  end

  def target_tile(max_range = nil)
    loop do
      # render the screen. this erases the inventory and shows the names of objects under the mouse.
      TCOD.console_flush
      TCOD.sys_check_for_event(TCOD::EVENT_KEY_PRESS | TCOD::EVENT_MOUSE, key, mouse)
      render_all

      x, y = mouse.cx, mouse.cy

      return [nil, nil] if mouse.rbutton_pressed || key.vk == TCOD::KEY_ESCAPE
      return [x, y] if mouse.lbutton_pressed && TCOD.map_is_in_fov(fov_map, x, y) &&
                       (max_range.nil? || player.distance(x, y))
    end
  end

  def target_monster(max_range = nil)
    loop do
      x, y = target_tile(max_range)
      return nil unless x

      monster = elements.select { |element| element.x == x && element.y == y && element.combatant && element != player }.first
      return monster
    end
  end

  def handle_keys
    if key.vk == TCOD::KEY_ENTER && key.lalt
      # Alt+Enter: toggle fullscreen
      TCOD.console_set_fullscreen(!TCOD.console_is_fullscreen)
    elsif key.vk == TCOD::KEY_ESCAPE
      return :exit  # exit game
    end

    if @game_state == :playing
      # movement keys
      if key.vk == TCOD::KEY_UP
        player_move_or_attack(0, -1)
      elsif key.vk == TCOD::KEY_DOWN
        player_move_or_attack(0, 1)
      elsif key.vk == TCOD::KEY_LEFT
        player_move_or_attack(-1, 0)
      elsif key.vk == TCOD::KEY_RIGHT
        player_move_or_attack(1, 0)
      else
        key_char = key.c

        if key_char == 'g'
          item_holder = elements.select { |element| element.x == player.x && element.y == player.y && !element.inventory.empty? }.first
          if item_holder
            player.pick_up(item_holder) if item_holder
          end
        end

        if key_char == 'i'
          chosen_item = inventory_menu("Press the key next to an item to use it or any other key to cancel\n")
          chosen_item.use_item if chosen_item
        end

        if key_char == 'd'
          chosen_item = inventory_menu("Press the key next to an item to drop it or any other key to cancel\n")
          elements << chosen_item.drop if chosen_item
        end

        return :didnt_take_turn
      end
    end
  end

  def render_bar(x, y, total_width, name, value, maximum, bar_color, back_color)
    bar_width = (value / maximum) * total_width
    TCOD.console_set_default_background(panel, back_color)
    TCOD.console_rect(panel, x, y, total_width, 1, false, TCOD::BKGND_SCREEN)

    TCOD.console_set_default_background(panel, bar_color)
    TCOD.console_rect(panel, x, y, bar_width, 1, false, TCOD::BKGND_SCREEN) if bar_width > 0

    TCOD.console_set_default_foreground(panel, TCOD::Color::WHITE)
    TCOD.console_print_ex(panel, x + total_width / 2, y, TCOD::BKGND_NONE,
                          TCOD::CENTER, "#{name}: #{value}/#{maximum}")
  end

  def render_all
    (0...MAP_HEIGHT).each do |y|
      (0...MAP_WIDTH).each do |x|
        visible = TCOD.map_is_in_fov(movement_manager.fov_map, x, y)
        wall = game_map[x][y].block_sight

        if visible
          if wall
            TCOD.console_put_char_ex(@con, x, y, '#'.ord, map.color_light_wall, map.color_light_ground)
          else
            TCOD.console_put_char_ex(@con, x, y, '.'.ord, map.color_light_wall, map.color_light_ground)
          end
        else
          if game_map[x][y].explored
            if wall
              TCOD.console_put_char_ex(@con, x, y, '#'.ord, map.color_dark_wall, map.color_dark_ground)
            else
              TCOD.console_put_char_ex(@con, x, y, '.'.ord, map.color_dark_wall, map.color_dark_ground)
            end
          end
        end
      end
    end

    elements.each { |element| element.draw unless element == player }
    player.draw
    TCOD.console_blit(con, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, nil, 0, 0, 1.0, 1.0)

    # prepare to render the GUI panel
    TCOD.console_set_default_background(panel, TCOD::Color::BLACK)
    TCOD.console_clear(panel)

    # print the game messages, one line at a time
    y = 1
    game_messages.each do |msg|
      TCOD.console_set_default_foreground(panel, msg[:color])
      TCOD.console_print_ex(panel, MSG_X, y, TCOD::BKGND_NONE, TCOD::LEFT, msg[:text])
      y += 1
    end

    # show the player's stats
    render_bar(1, 1, BAR_WIDTH, 'HP', player.combatant.hp, player.combatant.max_hp,
               TCOD::Color::LIGHT_RED, TCOD::Color::DARKER_RED)

    # display names of objects under the mouse
    TCOD.console_set_default_foreground(panel, TCOD::Color::LIGHT_GRAY)
    TCOD.console_print_ex(panel, 1, 0, TCOD::BKGND_NONE, TCOD::LEFT, get_names_under_mouse)

    # blit the contents of "panel" to the root console
    TCOD.console_blit(panel, 0, 0, SCREEN_WIDTH, PANEL_HEIGHT, nil, 0, PANEL_Y, 1.0, 1.0)
  end

  #############################################
  # Initialization & Main Loop
  #############################################
  def game_loop
    until TCOD.console_is_window_closed
      TCOD.console_set_default_foreground(con, TCOD::Color::WHITE)
      TCOD.sys_check_for_event(TCOD::EVENT_KEY_PRESS | TCOD::EVENT_MOUSE, key, mouse)

      render_all

      TCOD.console_flush
      elements.each(&:clear)

      # handle keys and exit game if needed
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
