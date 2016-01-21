class Clarification
  include Mongoid::Document
   field :entry,                   type: String, default: ''
   belongs_to :contest, :counter_cache => true
end
