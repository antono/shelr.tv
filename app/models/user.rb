class User < ActiveRecord::Base
  has_many :authentications, :dependent => :destroy
  has_many :client_applications
  has_many :tokens, class_name: 'OauthToken', order: "authorized_at desc", include: [:client_application]
  has_many :records, :dependent => :destroy

  before_save :activate_if_nickname_present

  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def editable_by?(user)
    id == user.id
  end

  private

  def activate_if_nickname_present
    self.activated = true unless self.nickname.blank?
  end
end
