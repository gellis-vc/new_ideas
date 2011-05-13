module Layout
  class Box
    attr_accessor :top, :left, :bottom, :right, :object, :color
    
    def initialize(left = 0, top = 0, right = 0, bottom = 0)
      @left, @top, @right, @bottom = left, top, right, bottom
    end

    def width
      [right - left, 0].max
    end

    def height
      [bottom - top, 0].max
    end

    def area
      width * height
    end
    
    def empty?
      right <= left || bottom <= top
    end
    
    def intersects?(other)
       self.left < other.right &&
      other.left <  self.right &&
        self.top < other.bottom &&
       other.top <  self.bottom
    end
    
    def hash
      ((left * 37 + right) * 23 + top) * 7 + bottom
    end
    
    def eql?(other)
          self.left == other.left &&
        other.right ==  self.right &&
           self.top == other.top &&
       other.bottom ==  self.bottom
    end
    
    def to_s
      "[#{left}...#{right},#{top}...#{bottom}]"
    end
  end
end
