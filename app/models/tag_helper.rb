module TagHelper
  def self.included(klass)
    klass.class_eval do
      
      validates_presence_of :name
      validates_uniqueness_of :name
      
      has_and_belongs_to_many :ideas, :join_table => "ideas_#{klass.table_name}".to_sym
      
      def self.from_string(tag_names)
        tags = []
        tag_names.strip.split(/,/).each do |tag_name|
          tags << find_or_create_by_name(tag_name) if !tag_name.blank?
        end
        tags
      end
  
      def self.find_or_create_by_name(tag_name)
        tag_name = tag_name.downcase.strip.gsub(/ +/, ' ')  # TODO: Strip punctuation, or...?
        find_by_name(tag_name) || create!(:name => tag_name)
      end
  
      def self.find_with_idea_counts(opts = {})
        cols = self.column_names.collect {|c| "#{self.to_s.tableize}.#{c}"}.join(",")
        opts.reverse_merge!(
          :select => "#{cols}, count(*) AS idea_count",
          :conditions => { 'ideas.hidden' => false, 'users.state' => 'active' },
          :joins => { :ideas => :inventor },
          :group => "#{cols}")
        find(:all, opts)
      end
      
      # Bulk loads all of the associated tags for the given ideas, to prevent a blizzard of individual queries.
      def self.load_tags(ideas)
        tags_by_idea = Hash.new{ |h,k| h[k] = [] }
        tags = find :all,
          :select => "#{table_name}.*, ideas_#{table_name}.idea_id",
          :joins => :ideas,
          :conditions => ['idea_id in (?)', ideas.map{ |idea| idea.id }]
        tags.each do |tag|
          tags_by_idea[tag.idea_id.to_i] << tag
        end
        ideas.each do |idea|
          # Setting idea.tags.target and idea.admin_tags.target bypasses loading of tags for each idea,
          # which is what causes the query barrage we're trying to prevent here. THIS SCREWS UP ANY UPDATES
          # to the tags / admin_tags association, so we mark it read only.
          idea.send(table_name.to_sym).target = tags_by_idea[idea.id]
          idea.readonly!
        end
      end
    
    end
  end
end
