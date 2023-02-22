# Rails Templates

Quickly generate a rails app with the default [Wagon](https://www.lewagon.com) configuration
using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).

⚠️ The following templates have been made for Rails 7. If you use Rails 6, please refer to the [`no-update` branch templates](https://github.com/lewagon/rails-templates/tree/no-update)

## Minimal

Get a minimal rails app ready to be deployed on Heroku with Bootstrap, Simple form and debugging gems.

```bash
rails new \
  -d postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/import-maps/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Devise

Same as minimal **plus** a Devise install with a generated `User` model.

```bash
rails new \
  -d postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/import-maps/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```
