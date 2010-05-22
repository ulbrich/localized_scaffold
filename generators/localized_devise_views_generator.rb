# Localized Rails scaffolding with style...

require 'rails/generators/erb'
require 'rails/generators/resource_helpers'
require 'rails/generators/erb/scaffold/scaffold_generator'

require File.join(File.dirname(__FILE__), 'localized_scaffold_generator')

require 'find'

# LocalizedDeviseViewsGenerator implements a generator doing the same as the
# devise_views generator shipped with devise but adding localization the same
# way as supported by the LocalizedScaffoldGenerator.
#
# Devise supports some localization but only for flashes and not for views.
# This generator adds its own "devise_views.en.yml" etc. files and uses these
# files for further localization. It also uses the title helper for title and
# headline which integrated better with the remaining application.
#
# The generator was not written from scratch but hijacks basic functionality
# from the scaffolding generator overwriting lookup rules to use the right
# templates.

class LocalizedDeviseViewsGenerator < Erb::Generators::Base
  desc "Creates a set of localized views for Devise using the provided model name
to access the user.

The required NAME parameter is the name of the model devise was installed to
run with (same you called \"rails generate devise\" with e.g. \"user\")."

  include Rails::Generators::ResourceHelpers

  # Returns a path relative to the generators directory optionally appending
  # the provided filename.
  #
  # Parameters:
  #
  # [filename] Filename or array of filenames to add (defaults to none)

  def self.generator_path(filename = '')
    return File.join(File.expand_path(File.dirname(__FILE__)), 
      'templates', 'devise', filename)
  end

  # Creates the views directory.

  def create_root_folder
    empty_directory File.join('app', 'views', 'devise')
  end

  # Generates all views in the views directory.

  def copy_view_files
    views = available_views

    views.each do |filename|
      template LocalizedDeviseViewsGenerator.generator_path(['views', filename]),
        File.join('app', 'views', 'devise', filename)
    end
  end

  # Copy locale files.
  
  def copy_standard_locales
    locales = LocalizedDeviseViewsGenerator.generator_path('locales')

    Dir.entries(locales).delete_if { |f| not f.match(/.*\.yml$/) }.each do |l|
      template File.join(locales, l), File.join('config', 'locales', l)
    end
  end

  # Copy of the scaffold layout and css file.

  def copy_layout_and_stylesheet_files
    template File.join(File.dirname(LocalizedDeviseViewsGenerator.generator_path),
      'erb', 'scaffold', filename_with_extensions(:layout)),
      File.join('app', 'views', 'layouts', filename_with_extensions('scaffold'))

    template File.join(File.dirname(LocalizedDeviseViewsGenerator.generator_path),
      'rails', 'stylesheets', 'templates', 'scaffold.css'),
      File.join('public', 'stylesheets', 'scaffold.css')
  end

  def name
    return @name.downcase
  end

protected

  # Returns the views to generate.

  def available_views
    genpath = LocalizedDeviseViewsGenerator.generator_path('views')
    views = []

    Find.find(genpath) { |f| views << f.sub(genpath, '') if File.stat(f).file? }

    return views
  end
end
