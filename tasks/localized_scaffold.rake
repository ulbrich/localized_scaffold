namespace :localized_scaffold do
  desc 'Downloads all available locales from git://github.com/svenfuchs/rails-i18n.git to "lib/locale".'
  task :download_locales => [:environment] do
    `rm -rf /tmp/rails-i18n`

    puts 'Downloading locale files...'

    `git clone git://github.com/svenfuchs/rails-i18n.git /tmp/rails-i18n 2> /dev/null`

    if $? != 0
      $stderr.puts '!!Missing git or network access to git://github.com/svenfuchs/rails-i18n.git'
    else
      `mkdir -p lib/locale`
      `cp -r /tmp/rails-i18n/rails/locale/* lib/locale`

      `rm -rf /tmp/rails-i18n`
    end

    puts 'Done'
  end
end
