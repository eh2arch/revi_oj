class Creator
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  has_one :user
  has_many :contests
  has_many :problems
end
