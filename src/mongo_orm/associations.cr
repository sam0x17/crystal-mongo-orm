module Mongo::ORM::Associations
  # define getter and setter for parent relationship
  macro belongs_to(model_name, class_name=nil)
    field {{class_name ? class_name.id.underscore.gsub(/::/,"_") : model_name.id}}_id : BSON::ObjectId

    # retrieve the parent relationship
    def {{model_name.id}}
      if parent = {{class_name ? class_name.id : model_name.id.camelcase}}.find {{class_name ? class_name.id.underscore.gsub(/::/,"_") : model_name.id}}_id
        parent
      else
        {{class_name ? class_name.id : model_name.id.camelcase}}.new
      end
    end

    # set the parent relationship
    def {{model_name.id}}=(parent)
      @{{class_name ? class_name.id.underscore.gsub(/::/,"_") : model_name.id}}_id = parent._id
    end
  end

  macro has_many(children_collection)
    def {{children_collection.id}}
      {% children_class = children_collection.id[0...-1].camelcase %}
      return [] of {{children_class}} unless self._id
      {{children_class}}.all({"#{self.class.to_s.underscore.gsub(/::/,"_")}_id" => self._id})
    end
  end
end
