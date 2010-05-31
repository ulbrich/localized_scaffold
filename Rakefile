# Localized Rails scaffolding with style...

require 'rubygems'
require 'rake/gempackagetask'

require 'find'

spec = Gem::Specification.new do |spec|
  files = []

  ['generators', 'lib', 'rails'].each { |dir|
    Find.find(dir) { |path| files << path if not File.stat(path).directory? } }

  files+= FileList['Gemfile', 'README.rdoc', '*.rb', 'test/*.rb'].to_a

  spec.platform = Gem::Platform::RUBY
  spec.name = 'localized_scaffold'
  spec.homepage = 'http://github.com/ulbrich/localized_scaffold'
  spec.version = '0.9.2'
  spec.author = 'Jan Ulbrich'
  spec.email = 'jan @nospam@ ulbrich.net'
  spec.summary = 'Localized Rails scaffolding with style...'
  spec.files = files
  spec.require_path = '.'
  spec.test_files = Dir.glob('test/*.rb')
  spec.has_rdoc = true
  spec.executables = []
  spec.extra_rdoc_files = ['README.rdoc']
  spec.rdoc_options << '--exclude' << 'init.rb' <<
    '--exclude' << 'install.rb' << '--exclude' << 'uninstall.rb' <<
    '--exclude' << 'pkg' << '--exclude' << 'generators/templates' <<
    '--exclude' << 'test' <<
    '--title' << '"Localized Scaffold"' << '--main' << 'README.rdoc'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
  puts 'Generated latest version.'
end

desc 'Remove directories "pkg" and "doc"'
task :clean do
  puts 'Remove directories "pkg" and "doc".'
  `rm -rf pkg doc`
end

desc 'Create rdoc documentation from the code'
task :doc do
  `rm -rf doc`

  puts 'Create rdoc documentation from the code'
  puts `(rdoc --exclude init.rb --exclude install.rb --exclude uninstall.rb \
          --exclude pkg --exclude generators/templates --exclude test \
          --all --title "Localized Scaffold" --main README.rdoc \
          README.rdoc generators) 1>&2`
end

desc 'Update the localized_scaffold.gemspec file with new snapshot of files to bundle'
task :gemspecs do
  puts 'Update the localized_scaffold.gemspec file with new snapshot of files to bundle.'

  # !!Warning: We can't use spec.to_ruby as this generates executable code
  # which would break Github gem generation...

  template = <<EOF
# Localized Rails scaffolding with style...

Gem::Specification.new do |spec|
  spec.platform = #{spec.platform.inspect}
  spec.name = #{spec.name.inspect}
  spec.homepage = #{spec.homepage.inspect}
  spec.version = "#{spec.version}"
  spec.author = #{spec.author.inspect}
  spec.email = #{spec.email.inspect}
  spec.summary = #{spec.summary.inspect}
  spec.files = #{spec.files.inspect}
  spec.require_path = #{spec.require_path.inspect}
  spec.has_rdoc = #{spec.has_rdoc}
  spec.executables = #{spec.executables.inspect}
  spec.extra_rdoc_files = #{spec.extra_rdoc_files.inspect}
  spec.rdoc_options = #{spec.rdoc_options.inspect}
end
EOF

  File.open('localized_scaffold.gemspec', 'w').write(template)
end
