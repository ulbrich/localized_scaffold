# The code in this file implements helper class ScaffoldHelper.

# Class ScaffoldHelper provides helpers available in all views and controllers
# using localized scaffolding.

module ScaffoldHelper
  
  # Sets the title and headline to display (actually done in the layout file).
  # Feel free to add more parameters for things like breadcrumbs...
  #
  # Parameters:
  #
  # [title] Title to set

  def title(text)
    content_for(:title) { text }
  end

  if not defined? root_path

    # Returns a default root path if no other route has been defined so far.

    def root_path
      return url_for('/')
    end
  end

  if not defined? root_path

    # Returns a default root URL if no other route has been defined so far.

    def root_url
      return url_for('/')
    end
  end
end
