require 'rubygems'
require 'rake'
require 'rake/clean'

require "#{File.dirname(__FILE__)}/lib/application"

task :default => :migrate

namespace :db do
  task :load_config do
    ActiveRecord::Base.establish_connection(Socrates::get_connection_string)
    ActiveRecord::Migrator.migrations_paths = [File.join(Socrates::root, 'db/migrate')]
  end

  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  task :environment do
    ActiveRecord::Base.establish_connection(Socrates::get_connection_string)
    ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
  end

  namespace :create do
    task :all => :load_config do
      ActiveRecord::Tasks::DatabaseTasks.create_all
    end
  end

end