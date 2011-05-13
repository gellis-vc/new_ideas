# Used by admin interface
module BucketHelper
  
  def bucket_contents
    # using map{find} instead of Idea.find(array) to preserve order, despite obvious inneficiency
    @bucket_contents ||= (session[:idea_bucket] || '').split(' ').map{ |id| Idea.find id }.select{ |idea| !idea.duplicate_of_id }
  end

  def update_bucket(opts)
    bucket_contents
    
    add    = Array(opts[:add] || [])
    remove = Array(opts[:remove] || [])
    (add + remove).each{ |idea| @bucket_contents.delete idea }
    @bucket_contents = (add + @bucket_contents).select{ |idea| !idea.duplicate_of_id }
    # @bucket_contents = @bucket_contents[0...20]  # uncomment to cap bucket size
    
    session[:idea_bucket] = @bucket_contents.map{ |idea| idea.id }.join(' ')
    
    @bucket_contents
  end

end
