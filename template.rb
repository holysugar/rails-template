#### Init

# TODO: ask?
locale = 'ja'
tz = 'Tokyo'

def wget(path, local = nil)
  local ||= path

  unless ENV['DEBUG']

    base_url = 'https://raw.github.com/holysugar/rails-template/master/'
    get base_url + path, local

  else
    directory = Pathname(File.dirname(__FILE__))
    FileUtils.copy("#{directory}/#{path}", local)
  end
end

def yesno?(statement, default=false, color=nil)
  if default == true || default == :yes
    !(ask(statement, color) =~ /\Ano?\z/) # not same as no?
  else
    yes?(statement, color)
  end
end

#### Gems

puts

using = {}

using[:gitinit]     = yesno?('Git initialize your project? [n]>', :no)

using[:heroku]      = yesno?('Use heroku? [n]>', :no)

if using[:heroku]
  gem 'pg'
  gem 'thin'
  gem 'foreman'
else
  gem 'mysql2'
  gem 'unicorn'
  gem 'thin', :group => :development
  gem 'capistrano', :group => :development
  gem 'capistrano-ext', :group => :development
end

using[:slim]        = yesno?('Use slim? [y]>', :yes)
if using[:slim]
  gem 'slim'
  gem 'slim-rails'
end

using[:haml]        = yesno?('Use haml? [y]>', :yes) unless using[:slim]
if using[:haml]
  gem 'haml'
  gem 'haml-rails'
end

using[:devise]      = yesno?('Use devise? [n]>', :no)
if using[:devise]
  gem 'devise'
end

using[:twitterbootstrap] = yesno?('Use twitter bootstrap? [y]>', :yes)
if using[:twitterbootstrap]
  gem 'twitter-bootstrap-rails', '>= 2.0.4'
  gem 'formtastic-bootstrap', \
#    :git => 'https://github.com/cgunther/formtastic-bootstrap',
#    :branch => 'bootstrap2-rails3-2-formtastic-2-1'
    :git => 'https://github.com/holysugar/formtastic-bootstrap',
    :branch => 'bootstrap2-rails3-2-formtastic-2-2',
    :require => 'formtastic-bootstrap'
end

gem 'bcrypt-ruby'
gem 'rails-i18n'
gem 'kaminari'
gem 'responders'
gem 'page_title_helper'
gem 'formtastic', ">= 2.2.0"

gem 'active_decorator'
gem 'enumerize'
gem 'therubyracer'

# In the group
append_file 'Gemfile', <<-EOG

# Utilities
#gem 'friendly_id'
#gem 'airbrake' # needs generating configuration
#gem 'compass'
#gem 'draper'
#gem 'paper_trail'
#gem 'validates_email_format_of', :git => 'git://github.com/alexdunae/validates_email_format_of.git'
#gem 'rack-contrib', :require => 'rack/contrib'
#gem 'term-ansicolor'
#gem 'rake-hook'
#gem 'configatron'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'ci_reporter'
  gem 'launchy'
  gem 'i18n_generators'
  gem 'rails-erd'
  gem 'rails_best_practices', :require => false
  gem 'pry'
  #gem 'jasmine'
  #gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git', :require => false
  #gem 'guard', :require => false
  #gem 'spork'
  #gem 'grit'
  #gem "email_spec"
end

group :test do
  gem 'rspec'
  gem 'capybara'
  #gem 'capybara-webkit'
  #gem 'headless'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'forgery'
end
EOG

run 'bundle install'

#### Deletion

remove_file 'public/index.html'
remove_file 'public/images/rails.png'
remove_file 'public/favicon.ico'
remove_file 'README'
remove_file '.gitignore'

#### Generation

application <<CONFIG
    config.time_zone = '#{tz}'
CONFIG

create_file 'README'

generate 'rspec:install'
generate 'devise:install' if using[:devise]

if using[:twitterbootstrap]
  generate 'bootstrap:install'
  wget 'config/initializers/formtastic.rb'
  insert_into_file 'app/assets/stylesheets/application.css', " *= formtastic-bootstrap\n", :before => " *= require_self"
end

wget 'dot.gitignore', '.gitignore'
wget 'config/config.yml' if using[:configatron]

if using[:heroku]
  wget 'Procfile'
else
  wget 'config/unicorn.rb'
#  run 'capify .'
#  wget 'deploy.rb', 'config/deploy.rb'
end

generate 'i18n', 'ja'

#### Git

if using[:gitinit]
  git :init
  git :add => '.'
  git :commit => "-a -m 'Initial commit'"
end

