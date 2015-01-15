class Creator
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  has_one :user
  has_and_belongs_to_many :contests
  has_and_belongs_to_many :problems
end
