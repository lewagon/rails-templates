## Rails Templates for Clever Cloud

Quickly generate a rails app with the default [Le Wagon](http://www.lewagon.org) configuration
and [Clever Cloud](http://clever-cloud.com/) configuration using
[Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).

### Minimal

```bash
rails _5.0.2_ new new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/master/clever_cloud/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

### Devise

```bash
rails _5.0.2_ new new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/master/clever_cloud/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```
