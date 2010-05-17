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
end
