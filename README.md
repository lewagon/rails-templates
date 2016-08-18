# Rails Templates

Quickly generate a rails app with the default [Wagon](http://www.lewagon.org) configuration
using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).


## Minimal

Get a minimal rails 5 app ready to be deployed on Heroku with Bootstrap, Simple form and
debugging gems.

```bash
rails new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/master/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Devise

Same as minimal **plus** a Devise install with a generated `User` model.


```bash
rails new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/master/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

# Testing

These templates are generated without a `test` folder (thanks to the `-T` flag). Starting from here, you can add Minitest & Capybara with the following procedure:

```ruby
# config/application.rb
require "rails/test_unit/railtie" # Un-comment this line
```

```bash
# In the terminal, run:
folders=(controllers fixtures helpers integration mailers models)
for dir in "${folders[@]}"; do mkdir -p "test/$dir" && touch "test/$dir/.keep"; done
cat >test/test_helper.rb <<RUBY
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all
end
RUBY
```

```bash
brew install phantomjs  # on OSX only
                        # Linux: see https://gist.github.com/julionc/7476620
```

```ruby
# Gemfile
group :development, :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'launchy'
  gem 'minitest-reporters'
  # [...]
end
```

```bash
bundle install
```

```ruby
# test/test_helper.rb
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

class ActiveSupport::TestCase
  fixtures :all
end

require 'capybara/rails'
class ActionDispatch::IntegrationTest
  include Capybara::DSL
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
    Warden.test_reset!
  end
end

require 'capybara/poltergeist'
Capybara.default_driver = :poltergeist

include Warden::Test::Helpers
Warden.test_mode!
```
