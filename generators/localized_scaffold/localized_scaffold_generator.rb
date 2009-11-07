# Load the original scaffold generator spotting the path from asking the
# rubygems system for help...

require File.join(File.dirname(File.dirname(Gem.bin_path('rails'))),
  'lib', 'rails_generator', 'generators', 'components', 'scaffold',
  'scaffold_generator')

# Just need to subclass the original to get everything we need: We only want
# to change the current directory to push underneath our own templates.

class LocalizedScaffoldGenerator < ScaffoldGenerator
  attr_reader :parent, :searchbar

  # Constructor setting up parent fake generator if --belongs_to option found.
  # This fake is used to forward calls like file_name in scope of the parent
  # object.
  #  
  # Parameters:
  #
  # [runtime_args] Command line parameters
  # [runtime_options] Generator options

  def initialize(runtime_args, runtime_options = {})
    super

    if ['url'].include? file_name # More to come...
      raise ArgumentError, "!!A model named #{file_name} will bring trouble."
    end

    @searchbar = options[:searchbar]

    if (parent_name = options[:belongsto])
      parent_attribute = "#{parent_name}_id"

      if runtime_args.join(',').index(parent_attribute).nil?
        raise ArgumentError, "!!Missing something like #{parent_attribute}:integer as attribute."
      end

      ScaffoldGenerator.spec = self.spec
      @parent = ScaffoldGenerator.new([parent_name], runtime_options)
    end
  end

  # Returns true if the generator should generate stuff in scope of a
  # parent controller.

  def has_parent?
    return (@parent != nil)
  end

  # Returns true if the generator should generate stuff including a searchbar.

  def has_searchbar?
    return (@searchbar != nil)
  end

  # Returns something to prefix controller routes with if rendering for a
  # parent.

  def parent_route_prefix_if_any
    if has_parent?
      return "/#{parent.table_name}/1"
    else
      return ''
    end
  end

  # Returns paths like "bar_path(@bar)" or "foo_bar_(@foo, @bar)" depending
  # on having a parent to set or not.
  #
  # Parameters:
  #
  # Options:
  #
  # [:method] Optional method (e.g. :edit, :new)
  # [:value1] First value to add to path
  # [:value2] Second value to add to path
  # [:extraargs] Additional stuff to add (e.g. ":q = c" for query)

  def path_of_with_parent_if_any(options = {})
    method = options[:method] || nil

    value1 = options[:value1] || "@#{singular_name}"
    value2 = options[:value2]
    
    value2 = "@#{parent.singular_name}" if has_parent? and value2.blank?

    extraargs = options[:extraargs]

    if not extraargs.blank?
      extraargs1 = ', ' + extraargs
      extraargs2 = '(' + extraargs + ')'
    end

    if has_parent?
      case method
      when nil
        return "#{parent.singular_name}_#{plural_name}_path(#{value2}#{extraargs1})"
      when :show
        return "#{parent.singular_name}_#{singular_name}_path(#{value2}, #{value1}#{extraargs1})"
      when :new
        return "new_#{parent.singular_name}_#{singular_name}_path(#{value2}#{extraargs1})"
      else
        return "#{method}_#{parent.singular_name}_#{singular_name}_path(#{value2}, #{value1}#{extraargs1})"
      end
    else
      case method
      when nil
        return "#{plural_name}_path#{extraargs2}"
      when :show
        return "#{singular_name}_path(#{value1}#{extraargs1})"
      when :new
        return "new_#{singular_name}_path#{extraargs2}"
      else
        return "#{method}_#{singular_name}_path(#{value1}#{extraargs1})"
      end
    end
  end

  # Override the original manifest adding the localization files.

  def manifest
    m = super # Assembled in yield, so remaining files have to be added manually

    m.directory(File.join('lib'))
    m.directory(File.join('app', 'locale'))

    lib_dir = File.join(File.dirname(__FILE__), 'lib')
    locale_dir = File.join(File.dirname(__FILE__), 'templates', 'locale')

    begin
      FileUtils.mkdir_p File.join('lib', 'locale')
      FileUtils.cp_r File.join(lib_dir, 'locale'), File.join('lib')
    rescue Exception
      # Already there, so just ignore...
    end

    Dir.entries(locale_dir).delete_if { |f| not f.match(/.*\.yml$/) }.each do |l|
      m.template("locale/#{l}", File.join('app/locale', "#{file_name}.#{l}"))
    end

    m.template('view_form.html.erb', File.join('app/views', controller_class_path,
      controller_file_name, '_form.html.erb'))

    if has_searchbar?
      if has_parent?
        patch = <<EOF

  validates_presence_of :#{searchbar}

  # Returns an array with the first chars of the #{searchbar} field and the
  # number of occurences in scope of the provided #{parent.file_name}.
  #
  # Parameters:
  #
  # [#{parent.file_name}_id] ID of the object to search in

  def self.#{searchbar}_chars(#{parent.file_name}_id)
    return #{class_name}.find(:all,
             :select => 'lower(substr(#{searchbar}, 1, 1)) as #{searchbar}_chars,
               count(*) as count',
             :conditions => ['#{parent.file_name}_id == ?', #{parent.file_name}_id],
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

      m.gsub_file "app/models/#{singular_name}.rb", /^(#{Regexp.escape("class #{class_name}")}.*)$/e do |match|
        "#{match}\n#{patch.chomp}"
      end
    end

    if has_parent?
      unless options[:pretend]
        m.gsub_file 'config/routes.rb', /(#{Regexp.escape("map.resources :#{plural_name}")})/mi do |match|
          "map.resources :#{parent.plural_name} do |#{parent.plural_name}|\n    #{parent.plural_name}.resources :#{plural_name}\n  end"
        end

        m.gsub_file "app/models/#{parent.singular_name}.rb", /^(#{Regexp.escape("class #{parent.class_name}")}.*)$/e do |match|
          "#{match}\n  has_many :#{plural_name}"
        end

        m.gsub_file "app/models/#{singular_name}.rb", /^(#{Regexp.escape("class #{class_name}")}.*)$/e do |match|
          "#{match}\n  belongs_to :#{parent.file_name}"
        end

        m.gsub_file "app/views/#{parent.plural_name}/show.html.erb", /^(#{Regexp.escape("<p>\n  <%= link_to t('standard.cmds.back')")}.*)$/e do |match|
          "<p>\n  <%= link_to t('#{file_name}.cmds.list'), #{path_of_with_parent_if_any}%>\n</p>\n\n#{match}"
        end
      end

      puts "\nThree things to know about the --belongs_to option of the generator as it messes
around with your models, views and routes:

1) The following is added to your routes and you might have a second look:

map.resources :#{parent.plural_name} do |#{parent.plural_name}|
  #{parent.plural_name}.resources :#{plural_name}
end

2) We also add a one-to-many relationship to your #{parent.class_name} model:

class #{parent.class_name} < ActiveRecord::Base
  has_many :#{plural_name}
end

3) Finally a link is added between the parent show view and the index view
of the new #{class_name} model (app/views/#{parent.plural_name}/show.html.erb):

<p>
  <%= link_to t('#{file_name}.cmds.list'), #{path_of_with_parent_if_any}%>
</p>

And please be sure to restart your server to asure new localization files are
loaded.

Here we go...\n\n"
    end

    return m
  end

  # Returns true if the will_paginate gem is installed. For more information
  # see gem "mislav-will_paginate" on github.com.

  def has_will_paginate?
    if not defined? @@has_will_paginate
      begin
        require 'will_paginate'
        @@has_will_paginate = true
      rescue Exception
        @@has_will_paginate = false
      end
    end

    return @@has_will_paginate
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

  # Returns the HTML to insert in the views header section. Done in a separate
  # method to ease customization.
  #
  # Parameters:
  #
  # [text] Text to display as header

  def view_header(text)
    return "<h1><%= #{text} %></h1>"
  end

  protected

    # Override with our own usage banner.

    def banner
      return "Usage: #{$0} localized_scaffold ModelName [field:type, field:type]"
    end

    # Override with adding own options.
    #
    # Parameters:
    #
    # [opt] Array of options

    def add_options!(opt)
      super

      opt.separator ''

      opt.on("-B", "--belongs_to=name", String,
        'Parent model this model belongs',
        'Default: None') { |v| options[:belongsto] = v }
      opt.on("-S", "--searchbar=name", String,
        'Column to base ABC and search bar on',
        'Default: None') { |v| options[:searchbar] = v }
    end
end
