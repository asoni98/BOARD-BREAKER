require 'rubygems'
require 'gosu'

module ZOrder
  Background = 0
  Boards = 1
  Person = 2
  UI = 4
end

class GameWindow < Gosu::Window
  def initialize
    $time = 0
    @minutes = 0
    super(640,480, false)
    self.caption = "Board Breaker"

    @background_image = Gosu::Image.new("media/TKD_Background.png")
    @music = Gosu::Sample.new("media/kungfu.mp3")
    @music.play(volume = 0.4, speed = 1, looping = true)
    @tkd_person_1 = Player.new
    @tkd_person_2 = Player.new
    @tkd_person_1.warp(220, 240)
    @tkd_person_2.warp(420, 240)

    @board_animation = Gosu::Image::load_tiles("media/board.png", 25, 25)
    @boards = Array.new
    @person = Array.new
    @font = Gosu::Font.new(20)
  end

  def update
    $time += 1
    # player one controls
    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft
      @tkd_person_1.turn_left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight
      @tkd_person_1.turn_right
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0
      @tkd_person_1.accelerate
    end
    if Gosu::button_down? Gosu::KbDown or Gosu::button_down? Gosu::GpButton0
      @tkd_person_1.deaccelerate
    end

    # player two controls
    if Gosu::button_down? Gosu::KbA or Gosu::button_down? Gosu::GpLeft
      @tkd_person_2.turn_left
    end
    if Gosu::button_down? Gosu::KbD or Gosu::button_down? Gosu::GpRight
      @tkd_person_2.turn_right
    end
    if Gosu::button_down? Gosu::KbW or Gosu::button_down? Gosu::GpButton0
      @tkd_person_2.accelerate
    end
    if Gosu::button_down? Gosu::KbS or Gosu::button_down? Gosu::GpButton0
      @tkd_person_2.deaccelerate
    end

    @tkd_person_1.move
    @tkd_person_2.move
    @tkd_person_1.collect_boards(@boards)
    @tkd_person_2.collect_boards(@boards)
    if rand(100) < 4 and @boards.size < 25
      @boards.push(Board.new(@board_animation))
    end

  end

  def draw

    @tkd_person_1.animate
    @tkd_person_2.animate
    @background_image.draw(0, 0, ZOrder::Background)
    @boards.each{ |board| board.draw}
    @font.draw("Score player 1: #{@tkd_person_1.score}", 140, 25, ZOrder::UI, 1.0, 1.0, 0xff_0000ff)
    @font.draw("Score player 2: #{@tkd_person_2.score}", 350, 25, ZOrder::UI, 1.0, 1.0, 0xff_ff0000)
    @seconds = $time/56
    @minutes = Time.at(@seconds).utc.strftime("%M:%S")
    @font.draw("Time: #{@minutes}", 265, 55, ZOrder::UI, 1.0, 1.0, 0xff_00ff00)
    if @minutes >= "01:00"
      if @tkd_person_1.score > @tkd_person_2.score
        @font.draw("Player 1 WON!!!!", 248, 80, ZOrder::UI, 1.0, 1.0, 0xff_0000ff)
      end
      if @tkd_person_2.score > @tkd_person_1.score
        @font.draw("Player 2 WON!!!!", 248, 80, ZOrder::UI, 1.0, 1.0, 0xff_ff0000)
      end
    end
  end
  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

end

class Player
  def initialize
    @image = Gosu::Image.new("media/tkd_image.bmp")
    @animation = Gosu::Image::load_tiles("media/TAEKWONDO_GUY.png", 50, 64)
    #Credits to Alejandro Hervella, junior at Staples High School, for his AMAZING animation skills in making a Taekwondo guy kicking
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def turn_left
    @angle -= 4.5
  end
  def turn_right
    @angle += 4.5
  end
  def accelerate
    @vel_x = Gosu::offset_x(@angle,3)
    @vel_y = Gosu::offset_y(@angle, 3)
  end
  def deaccelerate
    @vel_x = Gosu::offset_x(@angle, -3)
    @vel_y = Gosu::offset_y(@angle, -3)
  end
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480

    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
  def animate
    img = @animation[Gosu::milliseconds / 100 % @animation.size]
    img.draw_rot(@x, @y, 1, @angle)
  end

  def score
    @score
  end
  def collect_boards(boards)
    if boards.reject! {|board| Gosu::distance(@x, @y, board.x, board.y) < 35 }
      @score += 1
    end
  end
end

class Board
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color.argb(0xff_00ff00)
    @x = rand * 640
    @y = rand * 480
  end

  def draw
    img = @animation[1 / 100 % @animation.size]
    img.draw_rot(@x,@y,2, 90)
  end
end

window = GameWindow.new
window.show

#credits to https://github.com/gosu/gosu/wiki/Ruby-Tutorial for documenting basic gosu -
#- documentation and fundamentally teaching me how to make the controls, window, and interface
#credits to Mason Hale for demonstrating an example program (starfighter)
# citation: https://github.com/masonhale/Starfighter-Gosu-Tutorial