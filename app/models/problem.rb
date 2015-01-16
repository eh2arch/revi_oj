class Problem
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :name,                   type: String, default: ''
  field :pcode,                  type: String, default: ''
  field :state, 				 type: Boolean, default: true
  field :statement,				 type: String, default: ''
  field :time_limit,			 type: Float, default: '1.0'
  field :test_code,				 type: String, default: ''
  field :memory_limit,			 type: Integer, default: 268435456
  field :source_limit,			 type: Integer, default: 51200
  field :submissions_count,		 type: Integer, default: 0

  has_and_belongs_to_many :creators

  belongs_to :contest, :counter_cache => true

  has_many :submissions
  has_many :languages

end
