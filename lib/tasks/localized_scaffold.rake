namespace :localized_scaffold do
  desc 'Downloads all available locales from git://github.com/svenfuchs/rails-i18n.git to "lib/locale".'
  task :download_locales => [:environment] do
    `rm -rf /tmp/rails-i18n`

    puts 'Downloading locale files...'

    `git clone git://github.com/svenfuchs/rails-i18n.git /tmp/rails-i18n 2> /dev/null`

    if $? != 0
      $stderr.puts '!!Missing git or network access to git://github.com/svenfuchs/rails-i18n.git'
    else
      `mkdir -p config/locales`
      `cp -r /tmp/rails-i18n/rails/locale/* config/locales`

      `rm -rf /tmp/rails-i18n`
    end

    puts 'Done'
  end

  desc 'Adds i18n config to Rails::Initializer section of environment.rb.'
  task :configure => [:environment] do
    patch = <<EOF
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
    config.i18n.default_locale = :en
EOF
    path = File.expand_path(File.join(RAILS_ROOT, 'config', 'application.rb'))
    content = File.read(path)

    if content.match(/^\s+config.i18n.load_path/)
      puts 'Configuration seems already done. Please check manually!'
    else
      content.gsub!(/(Application < Rails::Application.*)$/) { |match| "#{match}\n#{patch}" }

      File.open(path, 'wb') { |file| file.write(content) }
    end
  end
end
