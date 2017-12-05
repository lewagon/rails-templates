run 'pgrep spring | xargs kill -9'

# GEMFILE
########################################
run 'rm Gemfile'
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '#{RUBY_VERSION}'

gem 'devise'
gem 'figaro'
gem 'jbuilder', '~> 2.0'
gem 'pg'
gem 'puma'
gem 'rails', '#{Rails.version}'
gem 'redis'

gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'jquery-rails'
gem 'sass-rails'
gem 'simple_form'
gem 'uglifier'

group :development do
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
RUBY

# Ruby version
########################################
file '.ruby-version', RUBY_VERSION

# Procfile
########################################
file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

# Spring conf file
########################################
inject_into_file 'config/spring.rb', before: ').each { |path| Spring.watch(path) }' do
  '  config/application.yml\n'
end

# Assets
########################################
run 'rm -rf app/assets/stylesheets'
run 'rm -rf vendor'
run 'curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip'
run 'unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets'

run 'rm app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js', <<-JS
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
JS

# Dev environment
########################################
gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

# Layout
########################################
run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>TODO</title>
    <%= csrf_meta_tags %>
    <%= action_cable_meta_tag %>
    <%= stylesheet_link_tag 'application', media: 'all' %>
  </head>
  <body>
    <%= render 'shared/navbar' %>
    <%= render 'shared/flashes' %>
    <%= yield %>
    <%= javascript_include_tag 'application' %>
  </body>
</html>
HTML

file 'app/views/shared/_flashes.html.erb', <<-HTML
<% if notice %>
  <div class="alert alert-info alert-dismissible" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <%= notice %>
  </div>
<% end %>
<% if alert %>
  <div class="alert alert-warning alert-dismissible" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <%= alert %>
  </div>
<% end %>
HTML

run 'curl -L https://raw.githubusercontent.com/lewagon/awesome-navbars/master/templates/_navbar_wagon.html.erb > app/views/shared/_navbar.html.erb'
run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/logo.png > app/assets/images/logo.png'

# README
########################################
markdown_file_content = <<-MARKDOWN
Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
MARKDOWN
file 'README.md', markdown_file_content, force: true

# Generators
########################################
generators = <<-RUBY
config.generators do |generate|
      generate.assets false
      generate.helper false
    end
RUBY

environment generators

########################################
# AFTER BUNDLE
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rake 'db:drop db:create db:migrate'
  generate('simple_form:install', '--bootstrap')
  generate(:controller, 'pages', 'home', '--skip-routes')

  # Routes
  ########################################
  route "root to: 'pages#home'"

  # Git ignore
  ########################################
  run 'rm .gitignore'
  file '.gitignore', <<-TXT
.bundle
log/*.log
tmp/**/*
tmp/*
*.swp
.DS_Store
public/assets
.byebug_history
TXT

  # Devise install + user
  ########################################
  generate('devise:install')
  generate('devise', 'User')

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<-RUBY
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
end
RUBY

  # migrate + devise views
  ########################################
  rake 'db:migrate'
  generate('devise:views')

  # Pages Controller
  ########################################
  run 'rm app/controllers/pages_controller.rb'
  file 'app/controllers/pages_controller.rb', <<-RUBY
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end
end
RUBY

  # Environments
  ########################################
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: 'development'
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: 'production'

  # Figaro
  ########################################
  run 'bundle binstubs figaro'
  run 'figaro install'

  # Git
  ########################################
  git :init
  git add: '.'
  git commit: "-m 'Initial commit with devise template from https://github.com/lewagon/rails-templates'"
end
