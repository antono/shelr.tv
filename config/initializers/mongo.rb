if ENV['MONGOHQ_URL']
  MongoMapper.config = { RAILS_ENV => {'uri' => ENV['MONGOHQ_URL']} }
end
