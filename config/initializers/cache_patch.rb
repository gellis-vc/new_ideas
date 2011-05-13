module ActionView::Helpers::CacheHelper
  
  alias_method :cache_without_options_patch, :cache
  
  def cache(name = {}, options = nil, &block)
    if options && options.has_key?(:if)
      return yield unless options[:if]
      options.delete :if
    end
    if options && options.has_key?(:unless)
      return yield if options[:unless]
      options.delete :unless
    end
    cache_without_options_patch(name, options, &block)
  end
end
