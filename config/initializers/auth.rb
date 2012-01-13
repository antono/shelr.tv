Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_ID'], ENV['GITHUB_SECRET']
  provider :twitter, 'LviFieaqd8pUfcfa8LxcNg', 'oSxUo8k6K9W47ku9l6x0F2m3O2D3u8FbrrT7ym1fI'

  # provider :openid, :store => OpenID::Store::Filesystem.new('/tmp')
end
