# Rails Templates

Quickly generate a rails app with the default [Wagon](https://www.lewagon.com) configuration
using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).


## Minimal

Get a minimal rails 5 app ready to be deployed on Heroku with Bootstrap, Simple form and debugging gems.

```bash
gem install rails -v 5.1.4 # Maybe you already have it :)
rails new \
  --database postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/rails-51/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Devise

Same as minimal **plus** a Devise install with a generated `User` model.

```bash
gem install rails -v 5.1.4 # Maybe you already have it :)
rails new \
  --database postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/rails-51/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```
