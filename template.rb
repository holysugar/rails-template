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
if using[:hamll]
  gem 'haml'
  gem 'haml-rails'
end

using[:devise]      = yesno?('Use devise? [n]>', :no)
if using[:devise]
  gem 'devise'
end

using[:configatron] = yesno?('Use configatron? [y]>', :yes)
gem 'configatron' if using[:configatron]

gem 'bcrypt-ruby'
gem 'rails-i18n'
gem 'kaminari'
gem 'jquery-rails'

gem 'inherited_resources'
gem 'formtastic'
gem 'friendly_id'
gem 'airbrake' # needs generating configuration
gem 'kaminari'
gem 'rake-hooks'

gem 'twitter-bootstrap-rails'
gem 'compass'

gem 'therubyracer'

# In the group
append_file 'Gemfile', <<-EOG

# Utilities
#gem 'draper'
#gem 'rails3_acts_as_paranoid'
#gem 'paper_trail'
#gem 'validates_email_format_of', :git => 'git://github.com/alexdunae/validates_email_format_of.git'
#gem 'rack-contrib', :require => 'rack/contrib'
#gem 'omniauth'
#gem 'oa-openid'
#gem 'cancan'
#gem "dalli"
#gem "comma"
#gem 'garb'
#gem 'term-ansicolor'
#gem 'carrierwave'
#gem 'fog'

#gem 'packed_fields', ">= 0.0.3"
#gem 'sexy_to_param'

group :development, :test do
  gem 'ir_b'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'ci_reporter'
  gem 'jasmine'
  gem 'rails_best_practices', :require => false
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git', :require => false
  gem 'launchy'
  gem 'i18n_generators'
  gem 'guard', :require => false
  gem 'grit'
  gem 'rails-erd'
  #gem "email_spec"
end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'spork', '~> 0.9.0.rc'
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

wget 'dot.gitignore', '.gitignore'
wget 'config/config.yml' if using[:configatron]
wget 'config/unicorn.rb' unless using[:heroku]

# unless using_heroku
#   run 'capify .'
#   remove_file 'config/deploy.rb'
#   wget 'deploy.rb', 'config/deploy.rb'
#   wget 'deploy/production.rb', 'config/deploy/production.rb'
#   wget 'deploy/staging.rb', 'config/deploy/staging.rb'
# end

generate 'i18n', 'ja'

#### Git

if using[:gitinit]
  git :init
  git :add => '.'
  git :commit => "-a -m 'Initial commit'"
end

