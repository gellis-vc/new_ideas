module Layout
  class Stack < Base
    
    def initialize(objects, opts = {}, &sizer)
      super(objects, opts, &sizer)
    end
    
  protected
    
    def do_layout(objects, opts)
      width, height, max_size, total_size = opts[:width], opts[:height], opts[:max_size], opts[:total_size]
      
      y = 0
      remaining_size = total_size
      remaining_height = height
      objects.each do |o|
        size = @sizer.call(o).to_f
        box = Box.new
        box.object = o
        box.top = y
        h = (size / remaining_size * remaining_height).round
        remaining_size -= size
        remaining_height -= h
        box.bottom = y = box.top + h
        obj_width = width * size / max_size
        box.left = (width - obj_width) / 3
        box.right = box.left + obj_width
        yield o, box
      end
    end
    
  end
end