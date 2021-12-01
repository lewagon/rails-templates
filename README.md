# Rails Templates

Quickly generate a **HOTWIRED** rails app based on the famous [Wagon "Devise" Template](https://github.com/lewagon/rails-templates/) using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html) and [Hotwire](https://github.com/hotwired/hotwire-rails)!


## Hotwire

Get a hotwire rails 6 app ready to be deployed on Heroku with Bootstrap, Simple form and debugging gems **plus** a Devise install with a generated `User` model.

```bash
rails new \
  --database postgresql \
  --webpack \
  -m https://raw.githubusercontent.com/ThibautBaissac/rails-templates/master/hotwire.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```
