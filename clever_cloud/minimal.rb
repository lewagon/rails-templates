run 'pgrep spring | xargs kill -9'

# GEMFILE
########################################
run 'rm Gemfile'
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '#{RUBY_VERSION}'

gem 'figaro'
gem 'jbuilder', '~> 2.0'
gem 'pg', '~> 0.21'
gem 'puma'
gem 'rails', '#{Rails.version}'
gem 'redis'

gem 'autoprefixer-rails'
gem 'bootstrap-sass', '~> 3.3'
gem 'font-awesome-sass', '~> 4.7'
gem 'sass-rails'
gem 'simple_form'
gem 'uglifier'
gem 'webpacker'

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

# Clevercloud conf file
########################################
file 'clevercloud/ruby.json', <<-EOF
{
  "deploy": {
    "rakegoals": ["assets:precompile", "db:migrate"]
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
  <<: *default
  url: <%= ENV['POSTGRESQL_ADDON_URI'] %>
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
//= require rails-ujs
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
    <%#= stylesheet_pack_tag 'application', media: 'all' %> <!-- Uncomment if you import CSS in app/javascript/packs/application.js -->
  </head>
  <body>
    <%= yield %>
    <%= javascript_include_tag 'application' %>
    <%= javascript_pack_tag 'application' %>
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
      generate.test_framework :test_unit, fixture: false
    end
RUBY

environment generators

########################################
# AFTER BUNDLE
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rails_command 'db:drop db:create db:migrate'
  generate('simple_form:install', '--bootstrap')
  generate(:controller, 'pages', 'home', '--skip-routes', '--no-test-framework')

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
!log/.keep
!tmp/.keep
*.swp
.DS_Store
public/assets
public/packs
public/packs-test
node_modules
.byebug_history
TXT

  # Webpacker / Yarn
  ########################################
  run 'rm app/javascript/packs/application.js'
  run 'yarn add jquery bootstrap@3'
  file 'app/javascript/packs/application.js', <<-JS
import "bootstrap";
JS

  inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
<<-JS
// Bootstrap 3 has a dependency over jQuery:
const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery'
  })
)

JS
  end

  # Figaro
  ########################################
  run 'bundle binstubs figaro'
  run 'figaro install'
  inside 'config' do
    figaro_yml = <<-EOF
production:
  RAILS_ENV: "production"
  SECRET_KEY_BASE: "#{SecureRandom.hex(64)}"
  STATIC_FILES_PATH: "/public/"
  CACHE_DEPENDENCIES: "true" # disable it when going live
EOF
    file 'application.yml', figaro_yml, force: true
  end

  # Git
  ########################################
  git :init
  git add: '.'
  git commit: "-m 'Initial commit with minimal template from https://github.com/lewagon/rails-templates'"
end
