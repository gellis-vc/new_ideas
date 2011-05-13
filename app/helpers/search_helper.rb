# Search logic shared by public & admin UIs. If you make changes to this code, be sure to test it
# on both the public and admin sides!

module SearchHelper
  
  # Performs a search for ideas based on a set of URL params, dispatching to the SQL or full-text
  # search as appropriate.
  def search_ideas(params)
    unless params[:search_text].blank?
      @body_class = "search"
      @query_title = "Search for \"#{params[:search_text]}\""
      search(Idea, params) do |results|
        results.select { |idea| idea.visible? }
      end
    else
      search_ideas_sql params
    end
  end
  
  # Handles SQL-based (i.e. not full-text) idea searches. Takes an array of search parameters
  # (which typically come from a URL path). For example: ["tag", "kumquats", "recent"]
  def search_ideas_sql(params)
    query_opts = {
      :page => params[:page] || 1,
      :per_page => params[:page_size] || 20,
      :include => [{:inventor => :postal_code}, :tags],
      :conditions => ['users.state = ? and ideas.hidden = ?', 'active', false] }
    @query_title = "Ideas"
    
    search_params = (params[:search] || 'recent').to_a.dup
    while !search_params.empty? do
      case param = search_params.shift
      when 'recent'
        query_opts[:order] = 'ideas.created_at DESC'
        query_opts[:conditions][0] += ' and ideas.duplicate_of_id is null'
        @query_title = "Recent " + @query_title
        @body_class ||= 'recent'
      when 'top-rated'
        query_opts[:order] = 'ideas.rating DESC, ideas.created_at DESC'
        query_opts[:conditions][0] += ' and ideas.duplicate_of_id is null'
        @query_title = "Top-Rated " + @query_title
        @body_class ||= 'top-rated'
      when 'tag'
        @body_class = "tag"
        tag_name = search_params.shift
        if tag_name
          query_opts[:conditions][0] += ' and ideas.duplicate_of_id is null'
          query_opts[:conditions][0] += ' and tags.name = ?'
          query_opts[:conditions] << tag_name
          @query_title += " Tagged \"#{tag_name}\""
          query_opts[:order] ||= if params[:format] == 'rss'
            'ideas.created_at DESC'
          else
            'ideas.rating DESC, ideas.created_at DESC'
          end
        end
      when 'current'
        current_id = search_params.shift
        query_opts[:conditions][0] += ' and ideas.current_id = ?'
        query_opts[:conditions] << current_id
        @query_title = "Currents " + @query_title
        @body_class ||= 'currents'
      else
        raise "Unknown search parameter \"#{param}\""
      end
    end
    
    Idea.paginate(query_opts)
  end
  
  # Handles geography-based searches
  def search_ideas_near_user(opts = {})
    postal_code = current_user.postal_code if logged_in?
    postal_code ||= PostalCode.find_by_text '55406'
    Idea.find(search_idea_ids_near(postal_code, opts))
  end
  
  def search_idea_ids_near(postal_code, opts = {})
    # This code uses a cheap flat earth distance formula, which is probably fine since it's only
    # used for sorting -- we never display the distance to the user. If we decide we actually care,
    # we can change it to use the more DB-taxing trig ... or even better, use a GIS plugin. -PPC
    unless postal_code.nil?
      Idea.find(:all,
        opts.reverse_merge(
          :select =>
          "ideas.id,
          pow(lat - (#{postal_code.lat}), 2) + pow(lon - (#{postal_code.lon}), 2) as distance",
        :conditions => [
          'lat > ? and lat < ? and lon > ? and lon < ? and users.state = ? and ideas.hidden = ? and ideas.marked_spam = ?',
          postal_code.lat - 4.0, postal_code.lat + 4.0,
          postal_code.lon - 4.6, postal_code.lon + 4.6,
          'active', false, false],
        :joins => {:inventor => :postal_code},
        :limit => 60,
        :order => 'distance, ideas.created_at desc'))
      else
        raise "You probably need to load your postal code seed data"
    end
  end
  
  # Searches for an arbitrary model using a full-text tsearch query. Shared by public & admin UI.
  def search(current_model, params, sort = nil, order = true, &filter)
    page = (params[:page] || 1).to_i
    page_size = (params[:per_page] || 30).to_i
    
    @search = current_model.find_by_tsearch(params[:search_text] || params[:search])
  
    WillPaginate::Collection.create(page, page_size, @search.size) do |pager|
      pager.replace(yield(@search))
    end
  end
  
end
