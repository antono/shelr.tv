# These tasks replace the built-in Rails tasks for dumping and loading the schema,
# allowing you to specify the FIXTURES_DIR to use for dumping and loading.
Rake.application.instance_eval do
  @tasks.delete "db:fixtures:load"
  @tasks.delete "db:fixtures:dump"
end


namespace :db do  
  namespace :fixtures do
    desc "Load fixtures into the current environment's database."
    task :load => :environment do
      prepare_connection_details
      db_to_load = Dir["#{@fixtures_dir}/*"].first.split("/").last
      cmd = "mongorestore #{@auth_options} --drop -d #{@db_name} #{@fixtures_dir}/#{db_to_load}"
      command_runner(cmd)
    end

    desc "Create bson fixtures from data in the current environment's database."
    task :dump => :environment do
      prepare_connection_details
      cmd = "mongodump #{@auth_string} --host #{@host} --port #{@port} -d #{@db_name} -o #{@fixtures_dir}"
      command_runner(cmd)
    end
  end
end

def command_runner(cmd)
  puts cmd
  `#{cmd}`
end

def prepare_connection_details
  @host, @port = Mongoid.database.connection.host_to_try
  @db_name = Mongoid.database.name
  auths = Mongoid.database.connection.auths
  if auths.length > 0
    @auth_string = "-u #{auths[0]["username"]} -p #{auths[0]["password"]}"
  end
  @fixtures_dir = ENV['FIXTURES_DIR'] || File.join(Rails.root, 'test', 'fixtures')
end
