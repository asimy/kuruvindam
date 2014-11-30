#!/usr/bin/env ruby
require 'libtcod'
require 'singleton'
require_relative 'lib/game_element'

class Rubylike
  include Singleton
  
  attr_reader :con, :elements, :player
  
  #actual size of the window
  SCREEN_WIDTH = 80
  SCREEN_HEIGHT = 50

  LIMIT_FPS = 20  #20 frames-per-second maximum

  def initialize(width = SCREEN_WIDTH, height = SCREEN_HEIGHT)
    TCOD.console_set_custom_font('arial10x10.png', TCOD::FONT_TYPE_GREYSCALE | TCOD::FONT_LAYOUT_TCOD, 0, 0)
    TCOD.console_init_root(SCREEN_WIDTH, SCREEN_HEIGHT, 'ruby/TCOD tutorial', false, TCOD::RENDERER_SDL)
    @con = TCOD.console_new(SCREEN_WIDTH, SCREEN_HEIGHT)
    TCOD.sys_set_fps(LIMIT_FPS)

    @player = GameElement.new(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, '@', TCOD::Color::GREEN, @con)
    @npc = GameElement.new(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, '@', TCOD::Color::YELLOW, @con)
    @elements = [@npc,@player]
    
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

  #############################################
  # Initialization & Main Loop
  #############################################
  def game_loop
    until TCOD.console_is_window_closed
      TCOD.console_set_default_foreground(con, TCOD::Color::WHITE)
      @elements.each {|obj| obj.draw }

      TCOD.console_blit(con, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, nil, 0, 0, 1.0, 1.0)
      TCOD.console_flush()
      @elements.each {|obj| obj.clear }

      #handle keys and exit game if needed
      will_exit = handle_keys
      break if will_exit
    end
    
  end

end

Rubylike.instance