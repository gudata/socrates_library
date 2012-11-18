require "rubygems"
require "bundler/setup"

require 'mysql2'
require 'fastercsv'
require 'active_record'
require 'active_support'
require 'awesome_print'
require 'logger'
require 'require_all'

# spierder that we use
require 'nokogiri'
require 'open-uri'
require 'awesome_nested_set'
require 'uri'
require 'cgi'

class Socrates

  def root
    Socrates::root
  end

  def env
    Socrates::env
  end

  def get_connection_string
    Socrates::env
  end

  def logger
    @@logger
  end

  class << self
    def logger
      return @@logger if defined? @@logger
      ActiveRecord::Base.logger = Logger.new(STDERR)
      @@logger = Logger.new(STDOUT) # Logger.new('logfile.log')
      @@logger.level = Logger::DEBUG
      @@logger
    end

    def root
      @@root ||= File.expand_path("../../", __FILE__)
    end

    def env
      @@env = ENV['SOCRATES_ENV'] || 'development'
    end

    def get_connection_string
      #    Dir[File.join(File.dirname(__FILE__), 'lib', 'models', '*.rb')].each {|file| require file }
      database_configuration = File.join(self.root, 'config', 'database.yml')
      Socrates::logger.info "connecting to #{database_configuration.inspect}"

      YAML::load(File.open(database_configuration))[Socrates::env]
    end
  end

  def initialize
    ActiveRecord::Base.establish_connection(Socrates::get_connection_string)
    require_all 'app/models'

  end

  def run crawler
    crawler.run
  end

end

