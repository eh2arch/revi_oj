class Language
  include Mongoid::Document

  field :name,                   type: String, default: 'cplusplus'
  field :langcode,               type: String, default: 'c++'
  field :time_multiplier,		 type: Float, default: '1.0'

  belongs_to :submission
  belongs_to :problem

end
