require 'digest/md5'

class User

  include Mongoid::Document

  field :email,         type: String,  unique: true
  field :nickname,      type: String,  unique: true
  field :records_count, type: Integer, default: 0
  field :api_key,       type: String,  unique: true
  field :twitter_id,    type: String, unique: true
  field :website,       type: String

  attr_accessible :nickname, :email, :website

  validates_uniqueness_of :nickname, :api_key, :twitter_id
  validates_length_of :nickname, maximum: 20

  references_many :records

  before_create :generate_api_key

  def to_param
    nickname
  end

  def editable_by?(user)
    return false if user.nil?
    self.id == user.id
  end

  def generate_api_key
    self.api_key = Digest::MD5.hexdigest(rand(1000).to_s)
  end

  def generate_api_key!
    generate_api_key && save
  end

end
