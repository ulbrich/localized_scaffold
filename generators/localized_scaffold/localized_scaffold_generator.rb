# Load the original scaffold generator spotting the path from asking the
# rubygems system for help...

require File.join(File.dirname(File.dirname(Gem.bin_path('rails'))),
  'lib', 'rails_generator', 'generators', 'components', 'scaffold',
  'scaffold_generator')

# Just need to subclass the original to get everything we need: We only want
# to change the current directory to push underneath our own templates.

class LocalizedScaffoldGenerator < ScaffoldGenerator
  attr_reader :parent

  # Constructor setting up parent fake generator if --parent option found.
  # This fake is used to forward calls like file_name in scope of the parent
  # object.
  #  
  # Parameters:
  #
  # [runtime_args] Command line parameters
  # [runtime_options] Generator options

  def initialize(runtime_args, runtime_options = {})
    super

    if (parent_name = options[:parent])
      parent_attribute = "#{parent_name}_id"

      if runtime_args.join(',').index(parent_attribute).nil?
        raise ArgumentError, "Missing something like #{parent_attribute}:integer as attribute!"
      end

      ScaffoldGenerator.spec = self.spec
      @parent = ScaffoldGenerator.new([parent_name], runtime_options)
    end
  end

  # Returns true if the generator should be generate stuff in scope of a
  # parent controller.

  def has_parent?
    return (@parent != nil)
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
  # [method] Optional method (e.g. :edit, :new)

  def path_of_with_parent_if_any(method = nil, value1 = nil, value2 = nil)
    value1 = "@#{singular_name}" if value1.blank?
    value2 = "@#{parent.singular_name}" if has_parent? and value2.blank?

    if has_parent?
      case method
      when nil
        return "#{parent.singular_name}_#{plural_name}_path(#{value2})"
      when :show
        return "#{parent.singular_name}_#{singular_name}_path(#{value2}, #{value1})"
      when :new
        return "new_#{parent.singular_name}_#{singular_name}_path(#{value2})"
      else
        return "#{method}_#{parent.singular_name}_#{singular_name}_path(#{value2}, #{value1})"
      end
    else
      case method
      when nil
        return "#{plural_name}_path"
      when :show
        return "#{singular_name}_path(#{value1})"
      when :new
        return "new_#{singular_name}_path"
      else
        return "#{method}_#{singular_name}_path(#{value1})"
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
      FileUtils.cp_r File.join(lib_dir, 'locale'), File.join('lib')
    rescue Exception
      # Already there, so just ignore...
    end

    Dir.entries(locale_dir).delete_if { |f| not f.match(/.*\.yml$/) }.each do |l|
      m.template("locale/#{l}", File.join('app/locale', "#{file_name}.#{l}"))
    end

    m.template('view_form.html.erb', File.join('app/views', controller_class_path,
      controller_file_name, '_form.html.erb'))

    if has_parent?
      unless options[:pretend]
        m.gsub_file 'config/routes.rb', /(#{Regexp.escape("map.resources :#{plural_name}")})/mi do |match|
          "map.resources :#{parent.plural_name} do |#{parent.plural_name}|\n    #{parent.plural_name}.resources :#{plural_name}\n  end"
        end

        m.gsub_file "app/models/#{parent.singular_name}.rb", /^(#{Regexp.escape("class #{parent.class_name}")}.*)$/e do |match|
          "#{match}\n  has_many :#{plural_name}\n"
        end

        m.gsub_file "app/views/#{parent.plural_name}/show.html.erb", /^(#{Regexp.escape("<p>\n  <%= link_to t('standard.cmds.back')")}.*)$/e do |match|
          "<p>\n  <%= link_to t('#{file_name}.cmds.list'), #{path_of_with_parent_if_any}%>\n</p>\n\n#{match}"
        end
      end

      puts "\nThree things to know about the --parent option of the generator as it messes
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

      opt.on("-P", "--parent=name", String,
        'Parent to add nested routing for',
        'Default: None') { |v| options[:parent] = v }
    end
end
