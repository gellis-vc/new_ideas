module Layout
  class FractalScatter < Base
    
    def initialize(objects, opts = {}, &sizer)
      super(objects, opts, &sizer)
    end
    
  protected
    
    def do_layout(objects, opts)
      width, height, max_size, total_size = opts[:width], opts[:height], opts[:max_size], opts[:total_size]
      
      remaining_size = total_size
      remaining_area = width * height * opts[:density]
      empty_space = [EmptySpace.new(0, 0, width, height, :center)]
      objects.each do |o|
        size = @sizer.call(o).to_f
        desired_area = size / remaining_size * remaining_area * opts[:favor_largest]
        break if desired_area <= 0
        
        empty_space = empty_space.sort_by{ |space| space.area }
        space = empty_space.last
        box_h = [Math.sqrt(desired_area) * 0.5, space.width * 0.95].min.round
        box_w = [desired_area / box_h, space.height * 0.95].min.round
        box_x, box_y = place_child_anchored(space, box_w, box_h, opts[:placements], opts[:initial_placement])
        box = Box.new(box_x, box_y, box_x + box_w, box_y + box_h)
        box.object = o
        
        yield box
        
        empty_space = empty_space.map{ |space| space.split_around(box) }.flatten.uniq
        remaining_size -= size
        remaining_area -= box.area
        break if empty_space.empty?
      end
    end
    
    def place_child_anchored(space, box_w, box_h, factors, center_factor)
      xfactor, yfactor = (
        case space.anchor_edge
        when :left  : [0, factors[0]]
        when :right : [1, factors[1]]
        when :top   : [factors[2], 0]
        when :bottom: [factors[3], 1]
        when :center: center_factor
        else
          raise "Unknown anchor edge #{space.anchor_edge.inspect}"
        end)
      [(xfactor * (space.width  - box_w) + space.left).round,
       (yfactor * (space.height - box_h) + space.top).round]
    end
  
    def place_child_randomly(space, box_w, box_h)
      [(rand * (space.width - box_w) + space.left).round,
       (rand * (space.height - box_h) + space.top).round]
    end
    
  private
    
    class EmptySpace < Box
      attr_reader :anchor_edge
      
      def initialize(left, top, right, bottom, anchor_edge)
        super(left, top, right, bottom)
        @anchor_edge = anchor_edge
      end
      
      def split_around(box)
        return self unless intersects?(box)
        [
          EmptySpace.new(box.right, top, right, bottom, :left),
          EmptySpace.new(left, box.bottom, right, bottom, :top),
          EmptySpace.new(left, top, box.left, bottom, :right),
          EmptySpace.new(left, top, right, box.top, :bottom)
        ].select{ |box| !box.empty? }
      end
    end
    
  end
end
