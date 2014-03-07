require 'gosu'

## Game Window
class GameWindow < Gosu::Window
  attr_reader :shots, :player_one, :player_two

  def initialize
    super 1024, 768, false
    self.caption = "Two ships shooting at eachother."
    @player_one = Player.new(self)
    @player_one.move(self.width - @player_one.image.width/2, self.height - @player_one.image.height/2)
    @player_two = Player.new(self)
    @player_two.move(@player_two.image.width/2,@player_two.image.height/2)
    @shots = []
  end

  def update

    ## Keyboard controls for player 1
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
      @shots << Shot.new(self,@player_one) unless
        @shots.select {|shot| shot.player == @player_one and Gosu::distance(shot.x, shot.y, shot.origin_x, shot.origin_y) < 300}.count > 0 # Don't shoot if just shot
    end

    ## Keyboard controls for player 2
    if button_down? Gosu::KbA then
      @player_two.turn_left
    end
    if button_down? Gosu::KbD  then
      @player_two.turn_right
    end
    if button_down? Gosu::KbW then
      @player_two.forward
    end

    # Exit with ESC
    if button_down? Gosu::KbE then
      @shots << Shot.new(self,@player_two) unless
        @shots.select {|shot| shot.player == @player_two and Gosu::distance(shot.x, shot.y, shot.origin_x, shot.origin_y) < 300}.count > 0 # Don't shoot if just shot
    end

    ## Handle shooting
    @shots.reject! { |shot| (shot.x > 1024 or shot.y > 768) or (shot.x < 0 or shot.y < 0) } # Remove shots that are off screen
    @shots.each { |shot| shot.update }
  end

  def draw
    @player_one.draw
    @player_two.draw
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
    @x ||= x; @y ||= y; @z ||= z
    @rotation ||= 0
    @image = Gosu::Image.new(window, image_file, false)
  end

  def update
  end

  def move(x,y,rotation=nil)
    @x = x; @y=y; @rotation = rotation if rotation
  end

  def draw
    @image.draw_rot(@x, @y, @z, @rotation)
  end
end

## Player object.  Handles space ships
class Player < GameObject
  attr_accessor :score
  def initialize(window,x=nil,y=nil)
    @z = 2
    super window,"media/Starfighter.bmp", x || window.height / 2, y || window.width / 2, 0
  end
  def turn_right
    @rotation +=  3
  end
  def turn_left
    @rotation -= 3
  end
  def forward
    @x += Gosu::offset_x(@rotation, 5) unless @x + @image.width/2 + Gosu::offset_x(@rotation, 5) > @window.width or @x - @image.width/2 + Gosu::offset_x(@rotation, 5) < 0
    @y += Gosu::offset_y(@rotation, 5) unless @y + @image.height/2 + Gosu::offset_y(@rotation, 5) > @window.height or @y - @image.height/2 + Gosu::offset_y(@rotation, 5) < 0
  end

end

## Shot Object handles players shooting.
class Shot < GameObject
  attr_reader :player,:origin_x,:origin_y
  def initialize(window,player)
    @player = player # need to know the owner of the shot.
    @origin_x = @player.x
    @origin_y = @player.y
    @rotation = @player.rotation
    @z = 1
    super window,"media/Shot.bmp", @origin_x, @origin_y
  end

  ## Make shots move across screen
  def update
    @x += Gosu::offset_x(@rotation, 10)
    @y += Gosu::offset_y(@rotation, 10)
  end
end

window = GameWindow.new
window.show
