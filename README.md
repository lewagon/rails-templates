# Rails Templates

Quickly generate a rails app with the default [Wagon](http://www.lewagon.org) configuration
using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).


## Minimal

Get a minimal rails app ready to be deployed on Heroku with Bootstrap, Simple form and
debugging gems.

```bash
rails _4.2.6_ new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/master/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Devise

Same as minimal **plus** a Devise install with a generated `User` model.


```bash
rails _4.2.6_ new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/master/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```
