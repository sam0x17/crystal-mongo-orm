module Mongo::ORM::Querying
  macro extended
    macro __process_querying
      \{% primary_name = PRIMARY[:name] %}
      \{% primary_type = PRIMARY[:type] %}

      def self.from_bson(bson)
        model = \{{@type.name.id}}.new
        model._id = bson["_id"].as(BSON::ObjectId)
        \{% for name, type in FIELDS %}
          model.\{{name.id}} = bson["\{{name}}"].as(Union(\{{type.id}} | Nil))
        \{% end %}
        \{% if SETTINGS[:timestamps] %}
          model.created_at = bson["created_at"].as(Union(Time | Nil))
          model.updated_at = bson["updated_at"].as(Union(Time | Nil))
        \{% end %}
        model
      end
    end
  end

  def clear
    collection.drop
  end

  def all(query = "", skip = 0, limit = 0, batch_size = 0, flags = LibMongoC::QueryFlags::NONE, prefs = nil)
    rows = [] of self
    collection.find(query, BSON.new, flags, skip, limit, batch_size, prefs).each do |doc|
      rows << from_bson(doc)
    end
    rows
  end

  def all_batches(query = "", batch_size = 100)
    collection.find(query, BSON.new, LibMongoC::QueryFlags::NONE, 0, 0, batch_size, nil).each do |doc|
      yield from_bson(doc)
    end
  end

  def first(query = "")
    all(query, 0, 1).first?
  end

  def find(value)
    return find_by(@@primary_name.to_s, value)
  end

  # find_by using symbol for field name.
  def find_by(field : Symbol, value)
    field = :_id if field == :id
    find_by(field.to_s, value)  # find_by using symbol for field name.
  end

  # find_by returns the first row found where the field maches the value
  def find_by(field : String, value)
    row = nil
    collection.find({ field => value }, BSON.new, LibMongoC::QueryFlags::NONE, 0, 1) do |doc|
      row = from_bson(doc)
    end
    row
  end

  def create(**args)
    create(args.to_h)
  end

  def create(args : Hash(Symbol | String, DB::Any))
    instance = new
    instance.set_attributes(args)
    instance.save
    instance
  end
end
