require 'digest/md5'

class User

  include Mongoid::Document

  field :email,         type: String,  unique: true
  field :nickname,      type: String,  unique: true
  field :records_count, type: Integer, default: 0
  field :api_key,       type: String,  unique: true
  field :twitter_id,    type: String,  unique: true
  field :twitter_name,  type: String,  unique: false # or we can block new users from registering
  field :website,       type: String
  field :about,         type: String
  field :created_at,    type: DateTime

  attr_accessible :nickname, :email, :website, :about

  validates_uniqueness_of :nickname, :api_key, :twitter_id
  validates_length_of :nickname, maximum: 20

  references_many :records

  before_create :generate_api_key, :timestamp!

  def to_param
    nickname
  end

  def avatar_url(size)
    return "/images/avatars/anonymous-#{size}.png" if nickname == 'Anonymous'
    unless email.blank?
      return "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{size}"
    else
      return "/images/avatars/default-#{size}.png"
    end
  end

  def editable_by?(user)
    return false if user.nil?
    return true  if user.nickname == 'antono'
    self.id == user.id
  end

  def generate_api_key
    self.api_key = Digest::MD5.hexdigest(rand(1000).to_s)
  end

  def generate_api_key!
    generate_api_key && save
  end

  def timestamp!
    write_attribute(:created_at, Time.now)
  end

end
