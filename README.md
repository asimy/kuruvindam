# Kuruvindam

This is a Ruby port of the game created in [RogueBasin](http://www.roguebasin.com)'s [Complete Roguelike Tutorial, using python+libtcod](http://www.roguebasin.com/index.php?title=Complete_Roguelike_Tutorial,_using_python%2Blibtcod) using a Ruby binding ([mispy/libtcod](http://github.com/mispy/libtcod)) for the “The Doryen Library”, [libtcod](http://roguecentral.org/doryen/libtcod/) a "free, fast, portable and uncomplicated API for roguelike developers".

I'm using it to understand how to write a roguelike (hence the lack of testing, stability and documentation). Once I've got the port working, I'll clean it up and write up a Ruby-flavored version of the tutorial.

## Prerequisites
This has only been tested under Mac OS X, but in principle should run under any system that can run Ruby 2 and which libtcod supports

## Installation

Grab a copy from github

    git clone https://github.com/asimy/kuruvindam.git kuruvindam

## Usage

To run the game,

    cd kuruvindam
    ruby kuruvindam.rb

### Game controls
These are *very* basic:

- Arrows keys move your character (currently represented by the classic '@'). Bump into monsters to attack them.
- Esc to exit the game
- option/alt-Return toggles full screen

## Todo

- Test on other platforms
- Finish the tutorial
- Fix all the things

## Contributing

1. Fork it ( https://github.com/asimy/kuruvindam/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
