# The code in this file implements helper class ScaffoldHelper.

# Class ScaffoldHelper provides helpers available in all views and controllers
# using localized scaffolding.

module ScaffoldHelper
  
  # Sets the title and headline to display (actually done in the layout file)
  # and optional breadcrumbs. The latter has to be an array of arrays with
  # path and label or label if not linkable.
  #
  # Parameters:
  #
  # [title] Title to set
  # [breadcrumbs] Optional breadcrumbs to set

  def title(title, breadcrumbs = nil)
    content_for(:title) { title }

    if not breadcrumbs.blank?
      content_for(:breadcrumbs) {
        cols = breadcrumbs.collect do |b|
          if b.kind_of? Array then
            content_tag(:li, link_to(b.last, b.first))
          else
            content_tag(:li, b, :class => 'decent')
          end
        end

       content_tag(:ul, ActiveSupport::SafeBuffer.new(cols.join),
         :id => 'breadcrumbs')
      }
    end
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
