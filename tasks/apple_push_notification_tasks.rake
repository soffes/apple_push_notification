namespace :apn do
  desc "migrates ugin's migration files into the database."
  task :migrate => :environment do

			 ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true 
			 ActiveRecord::Migrator.migrate(File.expand_path(File.dirname(__FILE__) + "/../lib/db/migrate"), ENV["VERSION"] ? ENV["VERSION"].to_i : nil)  
			 
			 Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby 
  end
end
