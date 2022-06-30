run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "autoprefixer-rails"
    gem "bootstrap"
    gem "font-awesome-sass", "~> 6.1"
    gem "simple_form", github: "heartcombo/simple_form"
  RUBY
end

gsub_file("Gemfile", '# gem "sassc-rails"', 'gem "sassc-rails"')

# Assets
########################################
run "rm -rf app/assets/stylesheets"
run "curl -L https://github.com/lewagon/rails-stylesheets/archive/vue.zip > stylesheets.zip"
run "unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-vue app/assets/stylesheets"

# Layout
########################################

gsub_file(
  "app/views/layouts/application.html.erb",
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
)

# README
########################################
markdown_file_content = <<~MARKDOWN
  Rails app generated with [lewagon/rails-templates-vue](https://github.com/lewagon/rails-templates/tree/vue), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
MARKDOWN
file "README.md", markdown_file_content, force: true

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

########################################
# After bundle
########################################
after_bundle do
  # Set up ImportMaps with Vue + Bootstrap
  ########################################
  run "rm -rf config/importmap.rb"
  run "touch config/importmap.rb"

  inject_into_file "config/importmap.rb" do
    <<~RUBY
      # Pin npm packages by running ./bin/importmap

      pin "application", preload: true
      pin_all_from "app/javascript/components", under: "components"
      pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
      pin "vue", to: 'https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.esm.browser.min.js'
      pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.1.3/dist/js/bootstrap.esm.js"
      pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.5/lib/index.js"
    RUBY
  end

  run "rm -rf app/javascript/controllers"
  run "mkdir app/javascript/components"

  run "rm app/javascript/application.js"
  run "touch app/javascript/application.js"

  inject_into_file "app/javascript/application.js" do
    <<~JS
      import "@hotwired/turbo-rails"
      import 'bootstrap';
    JS
  end

  # Generators: db + simple form + pages controller
  ########################################
  rails_command "db:drop db:create db:migrate"
  generate("simple_form:install", "--bootstrap")
  generate(:controller, "pages", "home", "--skip-routes", "--no-test-framework")

  # Routes
  ########################################
  route 'root to: "pages#home"'

  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT
    # Ignore .env file containing credentials.
    .env*

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  # Heroku
  run "bundle lock --add-platform x86_64-linux"

  # Rubocop
  ########################################
  run "curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml"

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with minimal template from https://github.com/lewagon/rails-templates/tree/vue'"
end
