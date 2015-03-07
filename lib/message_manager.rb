require 'singleton'

class MessageManager
  include Singleton

  attr_accessor :game_messages

  def initialize
    @game_messages = []
  end

  def message(new_msg, color = TCOD::Color::WHITE)
    new_msg_lines = word_wrap(new_msg, line_width: Kuruvindam::MSG_WIDTH)

    new_msg_lines.each_line do |line|
      # get rid of oldest line if the message list is at its max length
      game_messages.shift if game_messages.size == Kuruvindam::MSG_HEIGHT

      # use a two-element hash
      game_messages << { text: line, color: color }
    end
  end

  # stolen (:)) from ActionView::Helpers::TextHelper#word_wrap
  def word_wrap(text, options = {})
    line_width = options.fetch(:line_width, 80)

    text.split("\n").collect! do |line|
      line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
  end
end
