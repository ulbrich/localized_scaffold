# Localized Rails scaffolding with style...

Gem::Specification.new do |spec|
  spec.platform = "ruby"
  spec.name = "localized_scaffold"
  spec.homepage = "http://github.com/ulbrich/localized_scaffold"
  spec.version = "0.9.4"
  spec.author = "Jan Ulbrich"
  spec.email = "jan @nospam@ ulbrich.net"
  spec.summary = "Localized Rails scaffolding with style..."
  spec.files = ["generators/templates/test_unit/scaffold/templates/functional_test.rb", "generators/templates/rails/stylesheets/templates/scaffold.css", "generators/templates/rails/scaffold_controller/controller.rb", "generators/templates/rails/helper/scaffold_helper.rb", "generators/templates/rails/helper/helper.rb", "generators/templates/locales/en.yml", "generators/templates/locales/de.yml", "generators/templates/erb/scaffold/show.html.erb", "generators/templates/erb/scaffold/scaffold_generator.rb", "generators/templates/erb/scaffold/new.html.erb", "generators/templates/erb/scaffold/layout.html.erb", "generators/templates/erb/scaffold/index.html.erb", "generators/templates/erb/scaffold/edit.html.erb", "generators/templates/erb/scaffold/_index.html.erb", "generators/templates/erb/scaffold/_form.html.erb", "generators/templates/devise/views/unlocks/new.html.erb", "generators/templates/devise/views/shared/_links.erb", "generators/templates/devise/views/sessions/new.html.erb", "generators/templates/devise/views/registrations/new.html.erb", "generators/templates/devise/views/registrations/edit.html.erb", "generators/templates/devise/views/passwords/new.html.erb", "generators/templates/devise/views/passwords/edit.html.erb", "generators/templates/devise/views/mailer/unlock_instructions.html.erb", "generators/templates/devise/views/mailer/reset_password_instructions.html.erb", "generators/templates/devise/views/mailer/confirmation_instructions.html.erb", "generators/templates/devise/views/confirmations/new.html.erb", "generators/templates/devise/locales/devise_views.en.yml", "generators/templates/devise/locales/devise_views.de.yml", "generators/templates/devise/locales/devise.de.yml", "generators/templates/devise/locales/devise.de-FO.yml", "generators/localized_scaffold_generator.rb", "generators/localized_devise_views_generator.rb", "generators/locales/standard.en.yml", "generators/locales/standard.de.yml", "generators/locales/standard.de-FO.yml", "lib/tasks/localized_scaffold.rake", "rails/init.rb", "Gemfile", "README.rdoc", "init.rb", "install.rb", "localized_scaffold.rb", "uninstall.rb", "test/localized_scaffold_test.rb", "test/test_helper.rb"]
  spec.require_path = "."
  spec.has_rdoc = true
  spec.executables = []
  spec.extra_rdoc_files = ["README.rdoc"]
  spec.rdoc_options = ["--exclude", "init.rb", "--exclude", "install.rb", "--exclude", "uninstall.rb", "--exclude", "pkg", "--exclude", "generators/templates", "--exclude", "test", "--title", "\"Localized Scaffold\"", "--main", "README.rdoc"]
end
