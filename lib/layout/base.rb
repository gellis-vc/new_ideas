module Layout
  class Base
    
    attr_reader :boxes
    
    def initialize(objects, opts = {}, &sizer)
      @sizer = sizer
      color_scheme = opts[:color_scheme]
    
      @boxes = []
      sizes = objects.map { |o| sizer.call(o) }
      opts[:max_size] = sizes.max
      opts[:total_size] = sizes.sum
      
      i = 0
      do_layout(objects, opts) do |box|
        # weight = sizer.call(o) / opts[:max_size]
        weight = (1 - (i += 1).to_f / objects.size) ** 3
        box.color = color_scheme.color_for(box.object, weight)
        @boxes << box
      end
    end
    
    def merge!(other)
      @boxes += other.boxes
    end
    
  protected
    attr_reader :sizer
  
    def do_layout(objects, opts)
      raise "#{self.class} does not implement do_layout"
    end
    
  end
end