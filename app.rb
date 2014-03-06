require 'gosu'

## Game Window
class GameWindow < Gosu::Window
  def initialize
    super 1024, 768, false
    self.caption = "Two ships shooting at eachother."
    @player_one = Player.new(self)
    @shots = []
  end

  def update

    ## Keyboard controls
    if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft then
      @player_one.turn_left
    end
    if button_down? Gosu::KbRight or button_down? Gosu::GpRight then
      @player_one.turn_right
    end
    if button_down? Gosu::KbUp or button_down? Gosu::GpButton0 then
      @player_one.forward
    end
    if button_down? Gosu::KbRightShift then
      @shots << Shot.new(self,@player_one) unless @shots.select {|shot| shot.player == @player_one and Gosu::distance(shot.x, shot.y, shot.origin_x, shot.origin_y) < 200}.count > 0
    end

    ## Handle movement
    @shots.reject! { |shot| (shot.x > 1024 or shot.y > 768) or (shot.x < 0 or shot.y < 0) }
    @shots.each { |shot| shot.update }
    puts @shots.count
  end

  def draw
    @player_one.draw
    @shots.each { |shot| shot.draw }
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

## Basic Game Object will be inherited by other objects
class GameObject
  attr_accessor :score
  attr_reader :rotation, :z, :x, :y, :image
  def initialize(window,image_file,x=0,y=0,z=0)
    @window = window
    @x = x; @y = y; @z = z
    @rotation ||= 0
    @image = Gosu::Image.new(window, image_file, false)
  end

  def update
  end

  def draw
    @image.draw_rot(@x, @y, @z, @rotation)
  end
end

class Player < GameObject
  attr_accessor :score
  def initialize(window)
    @z = 2
    super window,"media/Starfighter.bmp",window.height / 2, window.width / 2, 0
  end
  def turn_right
    @rotation +=  2
  end
  def turn_left
    @rotation -= 2
  end
  def forward
    @x += Gosu::offset_x(@rotation, 3)
    @y += Gosu::offset_y(@rotation, 3)
  end

end

class Shot < GameObject
  attr_reader :player,:origin_x,:origin_y
  def initialize(window,player)
    @player = player
    @origin_x = @player.x
    @origin_y = @player.y
    @rotation = @player.rotation
    @z = 1
    super window,"media/Shot.bmp", @origin_x, @origin_y
  end
  def update
    @x += Gosu::offset_x(@rotation, 5)
    @y += Gosu::offset_y(@rotation, 5)
  end
end

window = GameWindow.new
window.show
