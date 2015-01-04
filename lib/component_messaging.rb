module ComponentMessaging

  def game
    owner.game
  end

  def message(text, color)
    if game
      game.message(text, color)
    else
      puts text
    end
  end

end