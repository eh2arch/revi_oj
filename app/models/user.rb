class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :username,           type: String, default: ""
  field :college,           type: String, default: ""
  field :encrypted_password, type: String, default: ""
  field :full_name,          type: String, default: ""
  field :phone,              type: String, default: ""
  field :birthdate,          type: Date, default: ""
  field :role,               type: String, default: ""
  # The admin can use this field to disallow the user to login
  field :disable,            type: Boolean, default: false
  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String

  # embedded_in :contest

  has_many :submissions
  has_and_belongs_to_many :contests
  belongs_to :creator

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time
  ROLES = %i[admin coder]


  class << self
    def serialize_from_session(key, salt)
      record = to_adapter.get(key[0]["$oid"])
      record if record && record.authenticatable_salt == salt
    end
  end

  before_save :init_user

  def init_user
    email = self[:email]
    system 'mkdir', '-p', "#{CONFIG[:base_path]}/#{email}"
    return true
  end

end
