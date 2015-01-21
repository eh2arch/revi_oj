class Language
  include Mongoid::Document

  field :name,                   type: String, default: 'c++'
  field :langcode,               type: String, default: 'c++'
  field :time_multiplier,		 type: Float, default: '1.0'

  has_many :submissions
  has_and_belongs_to_many :problems

end
