run "rm Gemfile"
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '#{Rails.version}'
gem 'puma'
gem 'pg'
gem 'figaro'
gem 'jbuilder', '~> 2.0'
gem 'devise'#{Rails.version >= "5" ? ", github: 'plataformatec/devise'" : nil}
gem 'redis'

gem 'sass-rails'
gem 'jquery-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'simple_form'#{Rails.version >= "5" ? ", github: 'plataformatec/simple_form'" : nil}
gem 'autoprefixer-rails'

group :development, :test do
  gem 'binding_of_caller'
  gem 'better_errors'
  #{Rails.version >= "5" ? nil : "gem 'quiet_assets'"}
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'spring'
  #{Rails.version >= "5" ? "gem 'listen', '~> 3.0.5'" : nil}
  #{Rails.version >= "5" ? "gem 'spring-watcher-listen', '~> 2.0.0'" : nil}
end

group :production do
  gem 'rails_12factor'
end
RUBY

file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

puma_file_content = <<-RUBY
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
RUBY

file 'config/puma.rb', puma_file_content, force: true

run "rm -rf app/assets/stylesheets"
run "curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip"
run "unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets"

run 'rm app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js', <<-JS
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
JS

if Rails.version >= "5"
  run "rm app/assets/javascripts/cable.coffee"
  file "app/assets/javascripts/cable.js", <<-JS
// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the rails generate channel command.
//
// Turn on the cable connection by removing the comments after the require statements (and ensure it's also on in config/routes.rb).
//
//= require action_cable
//= require_self
//= require_tree ./channels
// this.App || (this.App = {});
// App.cable = ActionCable.createConsumer();
  JS
end

gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <title>TODO</title>
    <%= csrf_meta_tags %>
    #{Rails.version >= "5" ? "<%= action_cable_meta_tag %>" : nil}
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <%= stylesheet_link_tag    'application', media: 'all' %>
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

run "curl -L https://raw.githubusercontent.com/lewagon/awesome-navbars/master/templates/_navbar_wagon.html.erb > app/views/shared/_navbar.html.erb"

run "rm README.rdoc"
markdown_file_content = <<-MARKDOWN
Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates)
MARKDOWN
file 'README.md', markdown_file_content, force: true

after_bundle do
  generate(:controller, 'pages', 'home', '--no-helper', '--no-assets', '--skip-routes')
  route "root to: 'pages#home'"

  run "rm .gitignore"
  file '.gitignore', <<-TXT
.bundle
log/*.log
tmp/**/*
tmp/*
*.swp
.DS_Store
public/assets
TXT
  run "bundle exec figaro install"
  generate('simple_form:install', '--bootstrap')
  generate('devise:install')
  generate('devise', 'User')
  generate('devise:views')
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: 'development'
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: 'production'
  rake 'db:drop db:create db:migrate'
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit with devise template from https://github.com/lewagon/rails-templates' }
end
