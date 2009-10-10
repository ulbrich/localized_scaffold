# Load the original scaffold generator spotting the path from asking the
# rubygems system for help...

require File.join(File.dirname(File.dirname(Gem.bin_path('rails'))),
  'lib', 'rails_generator', 'generators', 'components', 'scaffold',
  'scaffold_generator')

# Just need to subclass the original to get everything we need: We only want
# to change the current directory to push underneath our own templates.

class LocalizedScaffoldGenerator < ScaffoldGenerator

  # Override the original manifest adding the localization files.

  def manifest
    m = super # Assembled in yield, so remaining files have to be added manually

    m.directory(File.join('lib'))
    m.directory(File.join('app', 'locale'))

    lib_dir = File.join(File.dirname(__FILE__), 'lib')
    locale_dir = File.join(File.dirname(__FILE__), 'templates', 'locale')

    FileUtils.cp_r File.join(lib_dir, 'locale'), File.join('lib')

    Dir.entries(locale_dir).delete_if { |f| not f.match(/.*\.yml$/) }.each do |l|
      m.template("locale/#{l}", File.join('app/locale', "#{file_name}.#{l}"))
    end

    m.template('view_form.html.erb', File.join('app/views', controller_class_path,
      controller_file_name, '_form.html.erb'))

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
end