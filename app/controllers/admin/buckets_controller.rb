class Admin::BucketsController < ApplicationController
  
  include BucketHelper
  
  def add_idea
    update_bucket :add => idea
    render :partial => 'bucket'
  end
  
  def remove_idea
    update_bucket :remove => idea
    render :partial => 'bucket'
  end
  
private
  
  def idea
    @idea ||= Idea.find(params[:idea_id])
  end
  
end
