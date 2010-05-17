# Localized Rails scaffolding with style...

require 'rails/generators/rails/scaffold/scaffold_generator'
require 'rails/generators/rails/stylesheets/stylesheets_generator'
require 'rails/generators/test_unit/scaffold/scaffold_generator'

# Bring in our own ERB based scaffolding generator for views and layout.

require File.join(File.dirname(__FILE__), 'templates', 'erb', 'scaffold', 'scaffold_generator')

# To get our templates without copying them to "lib/templates" we overwrite
# the default templates path. This has no effect unless the generator is
# called so no need to iplement some initializer for that.

module Rails # :nodoc:
  module Generators # :nodoc:
    def self.templates_path # :nodoc:
      @templates_path = [File.expand_path(File.join(File.dirname(File.dirname(__FILE__)),
                          'generators', 'templates'))]
    end
  end
end

# Same for the stylesheets.

module Rails # :nodoc:
  module Generators # :nodoc:
    class StylesheetsGenerator # :nodoc:
      def self.source_root
        return File.expand_path(File.join(Rails::Generators.templates_path,
                  base_name, generator_name, 'templates'), File.dirname(__FILE__))
      end
    end
  end
end

# Same for the functional tests.

module TestUnit # :nodoc:
  module Generators # :nodoc:
    class ScaffoldGenerator # :nodoc:
      def self.source_root
        return File.expand_path(File.join(Rails::Generators.templates_path,
                  base_name, generator_name, 'templates'), File.dirname(__FILE__))
      end
    end
  end
end

# Generator derived from the original scaffold generator plus some helper
# methods used by the templates to control generated stuff.

class LocalizedScaffoldGenerator < Rails::Generators::ScaffoldGenerator
  attr_reader :listifies
  
  # Additional options supported by the localized scaffold generator

  class_option :belongsto, :type => :string, :desc => 'Optional "parent" model this resource belongs to', :default => nil
  class_option :searchbar, :type => :string, :desc => 'Optional attribute to generate a A B C searchbar for', :default => nil
  class_option :noshow, :type => :boolean, :desc => 'Optional flag to suppress generation of show view', :default => nil
  class_option :embed, :type => :string, :desc => 'Optional number of values to list in "parent" show view', :default => 0
  class_option :listify, :type => :string, :desc => 'Optional definition of localized values for fields', :default => nil

  # Overwritten consctructor for additional check for optional belongs_to
  # attribute.

  def initialize(*)
    super

    if shell.base.options[:belongsto] == 'belongsto'
      raise Thor::Error, '!!Missing model name for option --belongsto'
    end

    if shell.base.options[:searchbar] == 'searchbar'
      raise Thor::Error, '!!Missing field name for option --searchbar'
    end

    if (value = shell.base.options[:listify]) == 'listify'
      raise Thor::Error, '!!Missing model name for option --listify'
    end

    if value.blank?
      @listifies = {}
    else
      @listifies = {}

      value.gsub(/([:, ]) +/, '\1').split(' ').each do |set|
        field, values = set.split(':')

        @listifies[field] = values.split(',')
      end
    end

    if has_belongsto?
      attribute_name = "#{belongsto.class_name}_id".downcase

      if attributes.collect { |a| a.name.downcase }.index(attribute_name).nil?
        raise Thor::Error, "!!Missing something like #{attribute_name}:integer as attribute."
      end
    end
  end

  # Additional rule to copy scaffold helper.
  
  def copy_scaffold_helper
    copy_file File.join(Rails::Generators.templates_path, 'rails', 'helper',
      'scaffold_helper.rb'), File.join('app', 'helpers', 'scaffold_helper.rb')
  end

  # Additional rule to copy standard locales.
  
  def copy_standard_locales
    locales = File.expand_path(File.join(File.dirname(__FILE__), 'locales'))

    Dir.entries(locales).delete_if { |f| not f.match(/.*\.yml$/) }.each do |l|
      copy_file File.join(locales, l), File.join('config', 'locales', l)
    end
  end

  # Additional rules to create locale files for model.
  
  def create_scaffoled_locales
    locales = File.join(Rails::Generators.templates_path, 'locales')

    Dir.entries(locales).delete_if { |f| not f.match(/.*\.yml$/) }.each do |l|
      template File.join(locales, l), File.join('config', 'locales', "#{file_name}.#{l}")
    end
  end

  # Patch application controller to make sure that scaffold layout is used
  # and scaffold helpers are included. Patch routes and model if having a
  # belongs_to relationship.

  def patch_routes_and_more
    controller = File.join('app', 'controllers', 'application_controller.rb')

    if File.new(controller).grep(/layout *["'][^"']+["']/e).first.blank?
      gsub_file controller, /(.*class ApplicationController.*)$/e do |match|
        "#{match}\n  layout 'scaffold'\n"
      end
    end

    if File.new(controller).grep(/helper *:scaffold/).first.blank?
      gsub_file controller, /(.*class ApplicationController.*)$/e do |match|
        "#{match}\n  helper :scaffold\n"
      end
    end

    listify_methods = @listifies.collect do |field, values|
      values = values.collect { |v| ':' + v }.join(', ')

      "  # Returns an array with allowed #{field} values.

  def self.#{field.pluralize}
    return [#{values}]
  end

  # Returns a label for a certain #{file_name} #{field}.

  def self.#{field}_label(#{field})
    return I18n.t(\"#{file_name}.selects.#{field}.#" + "{#{field}}\")
  end

  # Returns a list of values for #{field.pluralize} suitable for a select tag.

  def self.#{field.pluralize}_for_select
    return #{field.pluralize}.collect { |v| [#{field}_label(v), v.to_s] }
  end"
    end

    if not listify_methods.empty?
      gsub_file File.join('app', 'models', "#{singular_name}.rb"),
        /^(end *)$/e do |match|
          "\n#{listify_methods.join("\n\n")}\n#{match}"
        end
    end

    if has_searchbar?
      if has_belongsto?
        patch = <<EOF

  validates_presence_of :#{searchbar}

  # Returns an array with the first chars of the #{searchbar} field and the
  # number of occurences in scope of the provided #{belongsto.file_name}.
  #
  # Parameters:
  #
  # [#{belongsto.file_name}_id] ID of the object to search in

  def self.#{searchbar}_chars(#{belongsto.file_name}_id)
    return #{class_name}.find(:all,
             :select => 'lower(substr(#{searchbar}, 1, 1)) as #{searchbar}_chars,
               count(*) as count',
             :conditions => ['#{belongsto.file_name}_id == ?', #{belongsto.file_name}_id],
             :order => 'lower(substr(#{searchbar}_chars, 1, 1)) asc',
             :group => 'lower(substr(#{searchbar}_chars, 1, 1))').collect { |s|
               [s.#{searchbar}_chars, s.count]
             }
  end
EOF
      else
        patch = <<EOF

  validates_presence_of :#{searchbar}

  # Returns an array with the first chars of the #{searchbar} field and the
  # number of occurences.

  def self.#{searchbar}_chars
    return #{class_name}.find(:all,
             :select => 'lower(substr(#{searchbar}, 1, 1)) as #{searchbar}_chars,
               count(*) as count',
             :order => 'lower(substr(#{searchbar}_chars, 1, 1)) asc',
             :group => 'lower(substr(#{searchbar}_chars, 1, 1))').collect { |s|
               [s.#{searchbar}_chars, s.count]
             }
  end
EOF
      end

      gsub_file File.join('app', 'models', "#{singular_name}.rb"),
        /^(#{Regexp.escape("class #{class_name}")}.*)$/e do |match|
          "#{match}\n#{patch.chomp}"
        end
    end

    if has_belongsto?
      unless options[:pretend]
        gsub_file File.join('config', 'routes.rb'),
          /(#{Regexp.escape("resources :#{plural_name}")})/mi do |match|
            "resources :#{belongsto.plural_name} do\n    resources :#{plural_name}\n  end"
          end

        gsub_file File.join('app', 'models', "#{belongsto.singular_name}.rb"),
          /^(#{Regexp.escape("class #{belongsto.class_name}")}.*)$/e do |match|
            "#{match}\n  has_many :#{plural_name}"
          end

        gsub_file File.join('app', 'models', "#{singular_name}.rb"),
          /^(#{Regexp.escape("class #{class_name}")}.*)$/e do |match|
            if embed?
              "#{match}\n  PARENT_EMBED = #{embed_max}\n\n  belongs_to :#{belongsto.file_name}"
            else
              "#{match}\n  belongs_to :#{belongsto.file_name}"
            end
          end

        begin
          gsub_file File.join('app', 'views', belongsto.plural_name, 'show.html.erb'),
            /^(#{Regexp.escape("<p>\n  <%= link_to t('standard.cmds.back')")}.*)$/e do |match|
              if embed?
                "<p>\n  <%= render :partial => '#{plural_name}/index', :locals => {
    :#{plural_name} => @#{belongsto.singular_name}.#{plural_name}.find(:all, :limit => #{class_name}::PARENT_EMBED + 1),
    :max => #{class_name}::PARENT_EMBED } %>\n</p>\n\n#{match}"
              else
                "<p>\n  <%= link_to t('#{file_name}.cmds.list'), #{path_of_with_belongsto_if_any}%>\n</p>\n\n#{match}"
              end
          end
        rescue Exception
          puts "!!Couldn't patch \"#{belongsto.plural_name}/show.html.erb\"."
        end
      end

      puts "\nThree things to know about the --belongsto option of the generator as it messes
around with your models, views and routes:

1) The following is added to your routes and you might have a second look:

resources :#{belongsto.plural_name} do |#{belongsto.plural_name}|
  resources :#{plural_name}
end

2) We also add a one-to-many relationship to your #{belongsto.class_name} model:

class #{belongsto.class_name} < ActiveRecord::Base
  has_many :#{plural_name}
end

3) Finally a link is added between the show and index views of the model the
new #{class_name} model belongs to (app/views/#{belongsto.plural_name}/show.html.erb):

<p>
  <%= link_to t('#{file_name}.cmds.list'), #{path_of_with_belongsto_if_any}%>
</p>

And please be sure to restart your server to asure new localization files are
loaded.

Here we go...\n\n"
    end
  end
end

# Additional methods needed in templates.

module Rails
  module Generators

    # Additional helpers needed by LocalizedScaffoldGenerator.

    module ResourceHelpers

      # Returns true if the generator should generate stuff in scope of a
      # "parent" resource as belongs_to relationship.

      def has_belongsto?
        return (not shell.base.options[:belongsto].blank?)
      end
      
      # Returns the name of the optional "parent" belongs_to relationship.

      def belongsto
        return @belongsto if defined? @belongsto

        if (str = shell.base.options[:belongsto]).blank?
          @belongsto = nil
        else
          @belongsto = ScaffoldGenerator.new([str])
        end

        return @belongsto
      end

      # Returns true if the generator should generate stuff including a
      # searchbar.

      def embed?
        value = shell.base.options[:embed]
        return (value.blank? ? false : (value.to_i > 0))
      end

      # Returns true if the generator should generate stuff including a
      # searchbar.

      def embed_max
        value = shell.base.options[:embed]
        return (value.blank? ? 0 : value.to_i)
      end

      # Returns true if the generator should generate stuff including a
      # searchbar.

      def has_searchbar?
        return (not shell.base.options[:searchbar].blank?)
      end

      # Returns the field to use for searchbar (if any).

      def searchbar
        return shell.base.options[:searchbar]
      end

      # Returns a hash of optional fields to handle as lists and their allowed 
      # values.

      def listifies
        return shell.base.listifies
      end

      # Returns true if show view should be generated. Redirects to index page
      # from action and suppresses generation of show view if not.
      
      def generate_showview?
         return (shell.base.options[:noshow] != true)
      end

      # Returns something to prefix controller routes with if rendering for a
      # belongsto.

      def belongsto_route_prefix_if_any
        if has_belongsto?
          return "/#{belongsto.table_name}/1"
        else
          return ''
        end
      end

      # Returns paths like "bar_path(@bar)" or "foo_bar_(@foo, @bar)" depending
      # on having a "parent" belongs_to relationship or not.
      #
      # Parameters:
      #
      # Options:
      #
      # [:method] Optional method (e.g. :edit, :new)
      # [:value1] First value to add to path
      # [:value2] Second value to add to path
      # [:extraargs] Additional stuff to add (e.g. ":q = c" for query)

      def path_of_with_belongsto_if_any(options = {})
        method = options[:method] || nil

        value1 = options[:value1] || "@#{singular_name}"
        value2 = options[:value2]
    
        value2 = "@#{belongsto.singular_name}" if has_belongsto? and value2.blank?

        extraargs = options[:extraargs]

        if not extraargs.blank?
          extraargs1 = ', ' + extraargs
          extraargs2 = '(' + extraargs + ')'
        end

        if has_belongsto?
          case method
          when nil
            return "#{belongsto.singular_name}_#{plural_name}_path(#{value2}#{extraargs1})"
          when :show
            return "#{belongsto.singular_name}_#{singular_name}_path(#{value2}, #{value1}#{extraargs1})"
          when :update
            return "#{belongsto.singular_name}_#{singular_name}_path(#{value2}, #{value1}#{extraargs1})"
          when :new
            return "new_#{belongsto.singular_name}_#{singular_name}_path(#{value2}#{extraargs1})"
          else
            return "#{method}_#{belongsto.singular_name}_#{singular_name}_path(#{value2}, #{value1}#{extraargs1})"
          end
        else
          case method
          when nil
            return "#{plural_name}_path#{extraargs2}"
          when :show
            return "#{singular_name}_path(#{value1}#{extraargs1})"
          when :update
            return "#{singular_name}_path(#{value1}#{extraargs1})"
          when :new
            return "new_#{singular_name}_path#{extraargs2}"
          else
            return "#{method}_#{singular_name}_path(#{value1}#{extraargs1})"
          end
        end
      end

      # Returns true if the will_paginate gem is installed. For more infos
      # see gem "mislav-will_paginate" on github.com.

      def has_will_paginate?
        if not defined? @has_will_paginate
          begin
            require 'will_paginate'
            @has_will_paginate = true
          rescue Exception
            @has_will_paginate = false
          end
        end

        return @has_will_paginate
      end

      # Returns true if JQuery Javascript library is there.

      def has_javascript_jquery?
        return File.exists?(File.join(RAILS_ROOT, 'public', 'javascripts',
                 'jquery.js'))
      end

      # Returns true if Prototype Javascript library is there.

      def has_javascript_prototype?
        return File.exists?(File.join(RAILS_ROOT, 'public', 'javascripts',
                 'prototype.js'))
      end
    end
  end
end