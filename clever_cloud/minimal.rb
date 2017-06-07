run 'pgrep spring | xargs kill -9'

# GEMFILE
########################################
run 'rm Gemfile'
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '#{RUBY_VERSION}'

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

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '~> 3.0.5'
  gem 'pry-byebug'
  gem 'pry-rails'
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

# Clevercloud conf file
########################################
file 'clevercloud/ruby.json', <<-EOF
{
  "deploy": {
    "env": "production",
    "rakegoals": ["assets:precompile", "db:migrate"],
    "static": "/public"
  }
}
EOF

# Database conf file
########################################
inside 'config' do
  database_conf = <<-EOF
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: #{app_name}_development

test:
  <<: *default
  database: #{app_name}_test

production:
  adapter:  postgresql
  encoding: utf8
  poll:     10
  host:     <%= ENV['POSTGRESQL_ADDON_HOST'] %>
  port:     <%= ENV['POSTGRESQL_ADDON_PORT'] %>
  database: <%= ENV['POSTGRESQL_ADDON_DB'] %>
  username: <%= ENV['POSTGRESQL_ADDON_USER'] %>
  password: <%= ENV['POSTGRESQL_ADDON_PASSWORD'] %>
EOF
  file 'database.yml', database_conf, force: true
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
    <%= yield %>
    <%= javascript_include_tag 'application' %>
  </body>
</html>
HTML

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
.clever.json
log/*.log
tmp/**/*
tmp/*
*.swp
.DS_Store
public/assets
TXT

  # Figaro
  ########################################
  run 'bundle binstubs figaro'
  run 'figaro install'
  inside 'config' do
    figaro_yml = <<-EOF
production:
  RAILS_ENV: "production"
  SECRET_KEY_BASE: "#{SecureRandom.hex(64)}"
EOF
    file 'application.yml', figaro_yml, force: true
  end

  # Git
  ########################################
  git :init
  git add: '.'
  git commit: "-m 'Initial commit with minimal template from https://github.com/lewagon/rails-templates'"
end
