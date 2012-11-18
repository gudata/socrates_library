# Как се инсталира
# ruby1.9 и rubygems после
#
# gem install bundler
# после от папката с проекта
# bundle
#
# как се прави базата данни
#
# rm -rf storage/ ; mysql -e "drop  database socrates_development" ; mysql -e "create database socrates_development DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"; rake db:migrate --trace
#
# как се пуска паяка
# ruby app/main.rb
#
# My notes on production
# mysql -pmysqlzaedno -e "drop  database socrates_development" ; mysql -pmysqlzaedno -e "create database socrates_development DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"; rake db:migrate --trace
#
require 'rubygems'


require "#{File.expand_path("../../", __FILE__)}/lib/application"


@main_app = Socrates.new

require_all 'app/crawlers'

@main_app.run(Stigabe.new(@main_app))