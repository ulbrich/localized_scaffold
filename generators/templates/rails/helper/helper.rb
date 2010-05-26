# The code in this file implements helper class <%= class_name %>Helper.

# Class <%= class_name %>Helper provides helpers available in all views of
# the <%= class_name %>Controller.

module <%= class_name %>Helper      
  
  # Returns a breadcrumbs for the current object (if any).
  
  def <%= shell.base.file_name %>_breadcrumbs
<%- if shell.base.has_belongsto? -%>
    breadcrumbs = [[root_path, t('standard.cmds.home')],
                    [<%= shell.base.belongsto.plural_name %>_path, t('<%= shell.base.belongsto.file_name %>.cmds.breadcrumb')],
                    [<%= shell.base.belongsto.file_name %>_path(@<%= shell.base.belongsto.file_name %>), @<%= shell.base.belongsto.file_name %>.to_s]]

    if defined? @<%= shell.base.file_name %> and not @<%= shell.base.file_name %>.blank?
<%- if shell.base.embed? -%>
      if @<%= shell.base.file_name %>.<%= shell.base.belongsto.file_name %>.<%= shell.base.table_name %>.count > <%= shell.base.class_name %>::PARENT_EMBED
        breadcrumbs << [<%= shell.base.path_of_with_belongsto_if_any %>, t('<%= shell.base.file_name %>.cmds.breadcrumb')]
      end

<%- else -%>
      breadcrumbs << [<%= shell.base.path_of_with_belongsto_if_any %>, t('<%= shell.base.file_name %>.cmds.breadcrumb')]
<%- end -%>
      breadcrumbs << @<%= shell.base.file_name %>.to_s if not @<%= shell.base.file_name %>.new_record?
    else
      breadcrumbs << t('<%= shell.base.file_name %>.cmds.breadcrumb')
    end
<%- else -%>
    breadcrumbs = [[root_path, t('standard.cmds.home')]]

    if defined? @<%= shell.base.file_name %> and not @<%= shell.base.file_name %>.blank?
      breadcrumbs << [<%= shell.base.path_of_with_belongsto_if_any %>, t('<%= shell.base.file_name %>.cmds.breadcrumb')]
      breadcrumbs << @<%= shell.base.file_name %>.to_s if not @<%= shell.base.file_name %>.new_record?
    else
      breadcrumbs << t('<%= shell.base.file_name %>.cmds.breadcrumb')
    end
<%- end -%>

    return breadcrumbs
  end
  
<%- if shell.base.has_will_paginate? -%>

  # Returns an interface for pagination using the will_paginate library.
  #
  # Parameters:
  #
  # [collection] Collection to paginate with
  # [options] Options to customize pager with

  def <%= shell.base.file_name %>_pagination(collection, options = {})
    if collection.total_entries > 1
      pager = will_paginate(collection, { :inner_window => 10,
                :next_label => t('standard.cmds.next_page'),
                :previous_label => t('standard.cmds.previous_page') }.merge(options))

      return (pager + ' |') if not pager.blank?
    end
    
    return ''
  end
<%- end -%>
<%- if shell.base.has_searchbar? -%>

  # Returns HTML for a searchbar with an A B C picker and a small form for
  # searching a <%= shell.base.searchbar %>.
  #
  # Parameters:
  #
  # [chars] Array with chars the <%= shell.base.searchbar %> of existing <%= plural_name %> start with
  # [term] Search term to render with

  def <%= shell.base.file_name %>_searchbar(chars, term)
    cols = ('a'..'z').collect do |c|
      if (same = ((not term.blank?) and c.upcase == term.upcase))
        inner = content_tag(:strong, c.upcase)
      elsif chars.include? c
        inner = link_to(c.upcase, <%= shell.base.path_of_with_belongsto_if_any(:extraargs => ':q => c') %>)
      else
        inner = c.upcase
      end

      content_tag(:td, inner, :class => (same ? 'selected' : nil))
    end

    value = (term.blank? or term.length > 1) ? term : t('standard.cmds.search')
    form = content_tag(:form, tag(:input, :type => :text,
             :id => 'searchbar-term', :name => 'q', :size => 12,
             :value => value), :method => 'get', :id => 'searchbar-form',
             :action => <%= shell.base.path_of_with_belongsto_if_any %>)

    cols << content_tag(:td, form)

    return content_tag(:table, content_tag(:tr,
             ActiveSupport::SafeBuffer.new(cols.join)), :class => 'searchbar')
  end
<%- end -%>
end
