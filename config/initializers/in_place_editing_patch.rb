module InPlaceEditing
  # PPC: This includes patches for http://dev.rubyonrails.org/ticket/6343 and http://dev.rubyonrails.org/ticket/9196
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        @item.update_attribute_without_validation_skipping(attribute, params[:value])
        render :text => ERB::Util.h(@item.send(attribute).to_s)
      end
    end
  end
end
