# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include SearchHelper
  
  def logged_in?
    !current_user.nil?
  end
  
  def user_formatted_text(text)
    # Handles free-form text for ideas and comments.
    # We could drop in some more elaborate formatting rules here if we want to,
    # but be careful about XSS attacks!
    auto_link(h(text).strip.gsub(/(\n|\r\n|\r)/, '<br/>'), :urls, {:rel => 'nofollow'})
  end
  
  def idea_owner?(idea)
    logged_in? && current_user.id == idea.inventor_id
  end
  
  def has_voted?(idea)
    # Cache all ideas voted on by this user to avoid doing O(n) queries
    @voted_for_idea_ids ||= if current_user
       Vote.find(:all, :conditions => {:user_id=>current_user.id}, :select=>'votes.idea_id').map{|x| x.idea_id}
    else
      []
    end
    
    logged_in? && (idea_owner?(idea) || @voted_for_idea_ids.include?(idea.id))
  end
  
  def flagged_as_inappropriate?(model)
    session[flagged_as_inappropriate_session_key(model)]
  end
  
  def flagged_as_inappropriate(model)
    session[flagged_as_inappropriate_session_key(model)] = true
  end
  
  def ideax_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {})
    in_place_editor_options.reverse_merge!(
      :save_text => 'Save',
      :cancel_text => 'Cancel',
      :options => '{}, highlightcolor: "#FFFFFF"')  # This is a nasty hack to disable the highlight, but it works
    in_place_editor_field(object, method, tag_options, in_place_editor_options)
  end
  
  # Path to full-page map for given ideas
  def map_ideas_path(ideas)
    map_path(:idea_ids => ideas.map{ |idea| idea.id }.join(' '))
  end
  
  # Creates a map object for the given ideas. The map_style can be :full or :mini.
  def map_ideas(ideas, opts = {})
    map_style = opts[:map_style]
    case map_style
      when :full
        map = GMap.new("map")
        map.control_init(:large_map => true, :map_type => false)
        zoom = DEFAULT_MAP_ZOOM
      when :mini
        map = GMap.new("minimap")
        zoom = DEFAULT_MINIMAP_ZOOM
        map.interface_init(Hash.new(false)) # disable dragging, etc.
      else
        raise "Unknown map_style #{map_style}"
    end
    
    map.icon_global_init(
      GIcon.new(
        :image =>  '/images/idea-marker.png',
        :icon_size => GSize.new(14,19),
        :icon_anchor => GPoint.new(7,16),
        :shadow => '/images/idea-shadow.png',
        :shadow_size => GSize.new(30,19)),
      :idea_icon)
    
    marker_locs = []
    ideas.each do |idea|
      zip = idea.inventor && idea.inventor.postal_code
      if zip
        icon_opts = {:icon => :idea_icon}
        if map_style == :full
          icon_opts[:info_window] = render_to_string(
            :partial => 'maps/idea_popup',
            :locals => { :idea => idea })
        else
          icon_opts[:clickable] = false
        end
        loc = [zip.lat + rand * 0.012, zip.lon + rand * 0.03]
        marker_locs << loc
        map.overlay_init(GMarker.new(loc, icon_opts))
      end
    end
    
    if opts[:autozoom] && !marker_locs.empty?
      map.center_zoom_on_points_init(*marker_locs)
    else
      map.center_zoom_init(DEFAULT_MAP_CENTER, zoom)
    end
    
    map
  end
  
  # IE doesn't fire onchange for checkboxes until blur. This helper method repeats a JS action
  # for change, click, and keypress actions so that checkboxes respond immediately in any browser.
  def check_box_onchange(action, opts = {:onchange => true})
    if opts[:onchange]
      { :onclick => action, :onkeypress => action, :onchange => action }
    else
      { :onclick => action, :onkeypress => action }
    end
  end
  
  def rss_date(time)
    time.strftime '%a, %d %b %Y %H:%M:%S %z'
  end
  
  def xml_pagination_attrs(p)
    { 'first-index' => (p.current_page-1) * p.per_page,
      'page-size' => p.per_page,
      'count' => p.size,
      'total-count' => p.total_entries }
  end

  def facebook_session
    session[:facebook_session]
  end

  def facebook_user
    (session[:facebook_session] && session[:facebook_session].session_key) ? session[:facebook_session].user : nil
  end

private
  
  def flagged_as_inappropriate_session_key(model)
    "xxx:#{model.class}:#{model.id}"
  end
  
  DEFAULT_MAP_CENTER = [39.232253, -96.503906]
  DEFAULT_MAP_ZOOM = 4
  DEFAULT_MINIMAP_ZOOM = 2
  
end
