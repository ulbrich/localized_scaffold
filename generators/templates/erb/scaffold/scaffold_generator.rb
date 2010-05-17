require 'rails/generators/erb'
require 'rails/generators/resource_helpers'
require 'rails/generators/erb/scaffold/scaffold_generator'

module Erb
  module Generators
    class ScaffoldGenerator < Base
      def self.generator_path(filename = '')
        return File.join(File.expand_path(File.dirname(__FILE__)), filename)
      end

      include Rails::Generators::ResourceHelpers

      argument :attributes, :type => :array, :default => [], :banner => 'field:type field:type'

      class_option :layout,    :type => :boolean
      class_option :singleton, :type => :boolean, :desc => 'Supply to skip index view'

      # Creates the views directory.

      def create_root_folder
        empty_directory File.join('app', 'views', controller_file_path)
      end

      # Generates all views in the views directory.

      def copy_view_files
        views = available_views
        views.delete('index') if options[:singleton]
        views.delete('_index') if not embed?
        views.delete('show') if not generate_showview?

        views.each do |view|
          filename = filename_with_extensions(view)

          template ScaffoldGenerator.generator_path(filename),
            File.join('app', 'views', controller_file_path, filename)
        end
      end

      # Forces a copy of the layout file.

      def force_copy_layout_file
        template ScaffoldGenerator.generator_path(filename_with_extensions(:layout)),
          File.join('app', 'views', 'layouts', filename_with_extensions('scaffold'))
      end

    protected

      # Returns the views to generate.

      def available_views
        %w(index edit show new _form _index)
      end
    end
  end
end
