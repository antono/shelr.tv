Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :github, ENV['GITHUB_ID'], ENV['GITHUB_SECRET'],
        :client_options => {:ssl => {:ca_path => '/etc/ssl/certs'}}

  provider :twitter, 'LviFieaqd8pUfcfa8LxcNg', 'oSxUo8k6K9W47ku9l6x0F2m3O2D3u8FbrrT7ym1fI'
  # provider :openid, :store => OpenID::Store::Filesystem.new('/tmp')
end
