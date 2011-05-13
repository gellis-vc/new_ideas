module Layout
  class CrazyColorScheme
    
    def color_for(object, weight)
      Color::HSL.new(rand * 360, 60 + rand * 30, 100 - weight * 60).html
    end
    
  end
end
