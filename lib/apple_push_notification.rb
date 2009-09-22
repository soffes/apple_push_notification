require File.join(File.dirname(__FILE__), "app", "models", "apple_push_notification.rb")

%w{ models }.each do |dir| 
	path = File.join(File.dirname(__FILE__), 'app', dir)  
	$LOAD_PATH << path 
	puts "Adding #{path}"
	ActiveSupport::Dependencies.load_paths << path 
	ActiveSupport::Dependencies.load_once_paths.delete(path) 
end 
