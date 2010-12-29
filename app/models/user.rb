class User < ActiveRecord::Base
  has_many :authentications
  has_many :client_applications
  has_many :tokens, class_name: 'OauthToken', order: "authorized_at desc", include: [:client_application]

  def apply_omniauth(omniauth)
    self.email = omniauth['user_info']['email'] if email.blank?
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end
end
