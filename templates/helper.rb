# The code in this file implements helper class <%= controller_class_name %>Helper.

# Class <%= controller_class_name %>Helper provides helpers available in all views of
# the <%= controller_class_name %>Controller.

module <%= controller_class_name %>Helper
<%- if has_will_paginate? -%>

  # Returns an interface for pagination using the will_paginate library.
  #
  # Parameters:
  #
  # [collection] Collection to paginate with
  # [options] Options to customize pager with

  def pagination(collection, options = {})
    if collection.total_entries > 1
      pager = will_paginate(collection, { :inner_window => 10,
                :next_label => t('standard.cmds.next_page'),
                :prev_label => t('standard.cmds.previous_page') }.merge(options))

      return (pager + ' |') if not pager.blank?
    end
    
    return ''
  end
<%- end -%>
end
