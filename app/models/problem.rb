class Problem
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :name,                   type: String, default: ''
  field :state, 				 type: Boolean, default: true
  field :statement,				 type: String, default: ''

  has_and_belongs_to_many :creators

  belongs_to :contest

end
