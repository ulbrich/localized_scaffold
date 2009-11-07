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

  def <%= file_name %>_pagination(collection, options = {})
    if collection.total_entries > 1
      pager = will_paginate(collection, { :inner_window => 10,
                :next_label => t('standard.cmds.next_page'),
                :prev_label => t('standard.cmds.previous_page') }.merge(options))

      return (pager + ' |') if not pager.blank?
    end
    
    return ''
  end
<%- end -%>
<%- if has_searchbar? -%>

  # Returns HTML for a searchbar with A B C etc. to pick and a small form
  # for searching a <%= searchbar %>.
  #
  # Parameters:
  #
  # [chars] Array with chars the <%= searchbar %> of existing <%= plural_name %> start with
  # [term] Search term to render with

  def <%= file_name %>_searchbar(chars, term)
    cols = ('a'..'z').collect do |c|
      if (same = (c == term))
        inner = content_tag(:strong, c.upcase)
      elsif chars.include? c
        inner = link_to(c.upcase, <%= path_of_with_parent_if_any(:extraargs => ':q => c') %>)
      else
        inner = c.upcase
      end

      content_tag(:td, inner, :class => (same ? 'selected' : nil))
    end

    value = (term.blank? or term.length > 1) ? term : t('standard.cmds.search')
    form = content_tag(:form, tag(:input, :type => :text,
             :id => 'searchbar-term', :name => 'q', :size => 12,
             :value => value), :method => 'get', :id => 'searchbar-form',
             :action => <%= path_of_with_parent_if_any %>)

    cols << content_tag(:td, form)

    return content_tag(:table, content_tag(:tr, cols), :class => 'searchbar')
  end
<%- end -%>
end
