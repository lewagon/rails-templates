file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '2.2.3'

gem 'rails', '4.2.3'
gem 'pg'
gem 'figaro'
gem 'jbuilder', '~> 2.0'

gem 'sass-rails', '~> 5.0'
gem 'jquery-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'simple_form'

group :development, :test do
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'quiet_assets'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'spring'
end

group :production do
  gem 'rails_12factor'
  gem 'puma'
end
RUBY

run "bundle install"
run "bundle exec figaro install"
run "curl -L https://gist.github.com/ssaunier/24bc1c4db955c19e3289/raw/install.sh | bash"

generate(:controller, 'pages', 'home', '--no-helper', '--no-assets')
route "root to: 'pages#home'"

generate('simple_form:install', '--bootstrap')
run "rm -rf app/assets/stylesheets"
run "curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip"
run "unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets"

file 'app/assets/javascripts/application.js', <<-JS
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
JS

file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <title>TODO</title>
    <%= stylesheet_link_tag    'application', media: 'all' %>
    <%= csrf_meta_tags %>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  </head>
  <body>
    <%= yield %>
    <%= javascript_include_tag 'application' %>
  </body>
</html>
HTML

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
