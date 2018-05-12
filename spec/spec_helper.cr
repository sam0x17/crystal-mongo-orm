require "../src/mongo_orm"
require "spec"

class TestUser < Mongo::ORM::Document
  field name : String
  field age : Int32
  field identifier : Int64
  field deleted_at : Time
  field stupid : Bool
  timestamps
end

class TestBlog < Mongo::ORM::EmbeddedDocument
  field name : String
  field description : String
  embeds thing : TestInnerThing
end

class TestPost < Mongo::ORM::Document
  field text : String
  belongs_to :test_admin
end

class TestInnerThing < Mongo::ORM::EmbeddedDocument
  field name : String
end

class TestAdmin < Mongo::ORM::Document
  field first_name : String
  field last_name : String
  field age : Int32
  embeds blog : TestBlog
  has_many :test_posts
  embeds_many :test_inner_things

  timestamps
end

class TestPoster < Mongo::ORM::Document
  field text : String
  belongs_to :test_admin, class_name: TestModule::TestModuleAdmin
end

module TestModule
  class TestModuleAdmin < Mongo::ORM::Document
    field first_name : String
    field last_name : String
    field age : Int32
    embeds blog : TestBlog
    has_many :test_posters
    embeds_many :test_inner_things
  
    timestamps
  end
end

Spec.before_each do
  TestUser.drop
  TestAdmin.drop
  TestPost.drop
  TestPoster.drop
  TestModule::TestModuleAdmin.drop
end

Spec.after_each do
  TestUser.drop
  TestAdmin.drop
  TestPost.drop
  TestPoster.drop
  TestModule::TestModuleAdmin.drop
end
