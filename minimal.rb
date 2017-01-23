run "pgrep spring | xargs kill -9"
run "rm Gemfile"
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '#{RUBY_VERSION}'

gem 'rails', '#{Rails.version}'
gem 'puma'
gem 'pg'
gem 'figaro'
gem 'jbuilder', '~> 2.0'
gem 'redis'

gem 'sass-rails'
gem 'jquery-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'simple_form'
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

#{Rails.version < "5" ? "gem 'rails_12factor', group: :production" : nil}
RUBY

file ".ruby-version", RUBY_VERSION

file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

inject_into_file 'config/spring.rb', before: ').each { |path| Spring.watch(path) }' do
  "  config/application.yml\n"
end

if Rails.version < "5"
puma_file_content = <<-RUBY
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i

threads     threads_count, threads_count
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
RUBY

file 'config/puma.rb', puma_file_content, force: true
end

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

gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>TODO</title>
    <%= csrf_meta_tags %>
    #{Rails.version >= "5" ? "<%= action_cable_meta_tag %>" : nil}
    <%= stylesheet_link_tag    'application', media: 'all' %>
  </head>
  <body>
    <%= yield %>
    <%= javascript_include_tag 'application' %>
  </body>
</html>
HTML

markdown_file_content = <<-MARKDOWN
Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
MARKDOWN
file 'README.md', markdown_file_content, force: true

generators = <<-RUBY
config.generators do |generate|
      generate.assets false
    end
RUBY

environment generators

after_bundle do
  rake 'db:drop db:create db:migrate'
  generate('simple_form:install', '--bootstrap')
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
  run "figaro install"
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit with minimal template from https://github.com/lewagon/rails-templates' }
end
