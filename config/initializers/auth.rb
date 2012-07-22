require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do

  provider :developer unless Rails.env.production?

  if Shelr.config['github']
    provider :github, Shelr.config['github']['id'], Shelr.config['github']['secret'],
             :client_options => {:ssl => {:ca_path => '/etc/ssl/certs'} }
  end

  if Shelr.config['twitter']
    provider :twitter, Shelr.config['twitter']['id'], Shelr.config['twitter']['secret']
  end

  if Shelr.config['google']
    provider :google_oauth2, Shelr.config['google']['id'], Shelr.config['google']['secret'], {
      :access_type => 'online',
      :approval_prompt => ''
    }
  end

  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
end
