unless Rails.env.test?
  Airbrake.configure do |config|
    config.api_key     = '23749797fdf7653d1621ddbad6a76dbd'
    config.host        = 'errbit.shelr.tv'
    config.port        = 80
    config.secure      = config.port == 443
  end
end
