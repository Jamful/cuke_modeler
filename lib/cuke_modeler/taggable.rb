module CukeModeler

  # NOT A PART OF THE PUBLIC API
  # A mix-in module containing methods used by models that represent an element that can be tagged.
  module Taggable

    # The models for tags which are directly assigned to the element
    attr_accessor :tags


    # Returns the models for tags which are indirectly assigned to the element (i.e. they
    # have been inherited from a parent element).
    def applied_tags
      parent_model.respond_to?(:all_tags) ? parent_model.all_tags : []
    end

    # Returns models for all of the tags which are applicable to the element.
    def all_tags
      applied_tags + @tags
    end


    private


    def tag_output_string
      tags.map(&:name).join(' ')
    end

    def populate_tags(model, parsed_model_data)
      return unless parsed_model_data['tags']

      parsed_model_data['tags'].each do |tag|
        model.tags << build_child_model(Tag, tag)
      end
    end

  end
end
