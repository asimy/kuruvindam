#!/usr/bin/env ruby
require 'libtcod'
require 'singleton'
require_relative 'lib/game_element'
require_relative 'lib/game_map'
require 'byebug'

class Rubylike
  include Singleton

  attr_reader :con, :elements, :player, :game_map

  #actual size of the window
  SCREEN_WIDTH = 80
  SCREEN_HEIGHT = 50

  MAP_WIDTH = 80
  MAP_HEIGHT = 45

  LIMIT_FPS = 20  #20 frames-per-second maximum

  def initialize(width = SCREEN_WIDTH, height = SCREEN_HEIGHT)
    TCOD.console_set_custom_font('arial10x10.png', TCOD::FONT_TYPE_GREYSCALE | TCOD::FONT_LAYOUT_TCOD, 0, 0)
    TCOD.console_init_root(SCREEN_WIDTH, SCREEN_HEIGHT, 'ruby/TCOD tutorial', false, TCOD::RENDERER_SDL)
    @con = TCOD.console_new(SCREEN_WIDTH, SCREEN_HEIGHT)
    TCOD.sys_set_fps(LIMIT_FPS)

    @map = GameMap.new(MAP_WIDTH, MAP_HEIGHT)
    @game_map = @map.game_map

    @player = GameElement.new(@map.starting_x, @map.starting_y, '@', TCOD::Color::GREEN, @con, @map, true)
    @map.fov_recompute(player: @player)
    @elements = [@player]

    game_loop
  end

  private

  def handle_keys
    #key = TCOD.console_check_for_keypress()  #real-time
    key = TCOD.console_wait_for_keypress(true)  #turn-based

    if key.vk == TCOD::KEY_ENTER && key.lalt
      #Alt+Enter: toggle fullscreen
      TCOD.console_set_fullscreen(!TCOD.console_is_fullscreen())
    elsif key.vk == TCOD::KEY_ESCAPE
      return true  #exit game
    end

    #movement keys
    if TCOD.console_is_key_pressed(TCOD::KEY_UP)
      @player.move(0, -1)
      @map.fov_recompute(player: @player)
    elsif TCOD.console_is_key_pressed(TCOD::KEY_DOWN)
      @player.move(0, 1)
      @map.fov_recompute(player: @player)
    elsif TCOD.console_is_key_pressed(TCOD::KEY_LEFT)
      @player.move(-1, 0)
      @map.fov_recompute(player: @player)
    elsif TCOD.console_is_key_pressed(TCOD::KEY_RIGHT)
      @player.move(1, 0)
      @map.fov_recompute(player: @player)
    end

    false
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

    @elements.each {|element| element.draw }
    TCOD.console_blit(con, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, nil, 0, 0, 1.0, 1.0)
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
      will_exit = handle_keys
      break if will_exit
    end

  end

end

Rubylike.instance