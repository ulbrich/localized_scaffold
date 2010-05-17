# Localized Rails scaffolding with style...

require 'rails/generators/erb'
require 'rails/generators/resource_helpers'
require 'rails/generators/erb/scaffold/scaffold_generator'

require File.join(File.dirname(__FILE__), 'localized_scaffold_generator')

require 'find'

class LocalizedDeviseViewsGenerator < Erb::Generators::Base
  def self.generator_path(filename = '')
    return File.join(File.expand_path(File.dirname(__FILE__)), 
      'templates', 'devise', filename)
  end

  desc "Creates a set of localized views for Devise using the provided model
name to access the user."

  include Rails::Generators::ResourceHelpers

  class_option :layout, :type => :boolean

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
