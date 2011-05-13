module Layout
  class GradientColorScheme
    
    def initialize(colors)
      @colors = colors.map{ |color| Color::RGB.from_html(color) }
    end
    
    def color_for(object, x)
      x = 1-x
      x *= @colors.size - 1
      i = x.to_i
      w = x % 1
      if w > 0
        @colors[i+1].mix_with(@colors[i], w * 100).html
      else
        @colors[i].html
      end
    end
    
  end
end
