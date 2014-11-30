#!/usr/bin/env ruby
require 'libtcod'
require 'singleton'
require_relative 'lib/game_element'
require_relative 'lib/game_map'

class Rubylike
  include Singleton
  
  attr_reader :con, :elements, :player, :map
  
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

    m = GameMap.new(MAP_WIDTH, MAP_HEIGHT)
    @map = m.game_map
    
    @player = GameElement.new(m.starting_x, m.starting_y, '@', TCOD::Color::GREEN, @con, @map)
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
    elsif TCOD.console_is_key_pressed(TCOD::KEY_DOWN)
      @player.move(0, 1)
    elsif TCOD.console_is_key_pressed(TCOD::KEY_LEFT)
      @player.move(-1, 0)
    elsif TCOD.console_is_key_pressed(TCOD::KEY_RIGHT)
      @player.move(1, 0)
    end

    false
  end
  
  def render_all
    color_dark_wall = TCOD::Color.rgb(0, 0, 100)
    color_dark_ground = TCOD::Color.rgb(50, 50, 150)
    
    (0...MAP_HEIGHT).each do |y|
      (0...MAP_WIDTH).each do |x|
      
        if @map[x][y].block_sight
          TCOD.console_put_char_ex(@con, x, y, '#'.ord, TCOD::Color::WHITE, TCOD::Color::BLACK)
        else
          TCOD.console_put_char_ex(@con, x, y, '.'.ord, TCOD::Color::WHITE, TCOD::Color::BLACK)
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