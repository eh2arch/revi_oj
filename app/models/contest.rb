class Contest
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :name,                   type: String, default: ''
  field :ccode,                  type: String, default: ''
  field :start_time,             type: DateTime, default: DateTime.now
  field :end_time,				 type: DateTime, default: DateTime.now + 3.hours
  field :state, 				 type: Boolean, default: true

  has_and_belongs_to_many :creators

  has_and_belongs_to_many :users
  has_many :problems

end
