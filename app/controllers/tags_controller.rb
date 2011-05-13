class TagsController < ApplicationController
  
  def index
    @body_class = "tags-page"
  end
  
  def current_objects
    unless @tags
      @tags = Tag.find_top_tags 100
      return if @tags.empty?
      idea_counts = @tags.map{ |tag| tag.idea_count.to_i }
      @min_idea_count = Math.sqrt(idea_counts.min)
      @max_idea_count = Math.sqrt(idea_counts.max)
    end
    @tags
  end
  helper_method :current_objects
  
  def tag_style(tag, min_percent, max_percent)
    size = (Math.sqrt(tag.idea_count) - @min_idea_count) / (@max_idea_count - @min_idea_count)
    size = size * (max_percent - min_percent) + min_percent
    "font-size: #{size}%"
  end
  helper_method :tag_style
  
end
