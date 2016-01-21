class Contest
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :name,                   type: String, default: ''
  field :ccode,                  type: String, default: ''
  field :start_time,             type: DateTime, default: DateTime.now
  field :end_time,				 type: DateTime, default: DateTime.now + 3.hours
  field :state, 				 type: Boolean, default: true

  belongs_to :creator, :counter_cache => true
  has_many :clarifications, :dependent => :destroy
  accepts_nested_attributes_for :clarifications, :allow_destroy => true

  has_and_belongs_to_many :users
  has_many :problems

  before_save :create_contest_folder

  def create_contest_folder
  	users = self.users
  	users.each do |user|
	    email = user[:email]
	    system 'mkdir', '-p', "#{CONFIG[:base_path]}/#{email}/#{self[:ccode]}"
  	end
  	system 'mkdir', '-p', "#{CONFIG[:base_path]}/contests/#{self[:ccode]}"
    return true
  end

end
