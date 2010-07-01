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
  # [options] Options to customize pager with plus own :delimiter option

  def <%= shell.base.file_name %>_pagination(collection, options = {})
    delimiter = options.delete(:delimiter) || '|'

    if collection.total_pages > 1
      pager = will_paginate(collection, { :inner_window => 10,
                :next_label => t('standard.cmds.next_page'),
                :previous_label => t('standard.cmds.previous_page') }.merge(options))

      return (pager + ' ' + delimiter) if not pager.blank?
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
  # [chars] Array with <%= shell.base.searchbar %> chars of existing <%= plural_name %> start with
  # [term] Search term to render with
  # [:options] Options to customize
  #
  # Options:
  #
  # [:type] What to render (:abc, :form or :both)
  # [:default] Default search term to show in input field (localized value)
  # [:size] Size of input field (defaults to 12)
  # [:format] Type of HTML to generate (:table or :ul defaulting to :table)

  def <%= shell.base.file_name %>_searchbar(chars, term, options = {})
    type = options[:type] || 'both'
    default = options[:default] || t('standard.cmds.search')
    size = options[:size] || 12

    format = options[:format] || :table
    inner_tag = (format == :ul ? 'li' : 'td')

    if type == :form
      cols = []
    else
      cols = ('a'..'z').collect do |c|
        if (same = ((not term.blank?) and c.upcase == term.upcase))
          inner = content_tag(:strong, c.upcase)
        elsif chars.include? c
          inner = link_to(c.upcase, <%= shell.base.path_of_with_belongsto_if_any(:extraargs => ':q => c') %>)
        else
          inner = c.upcase
        end

        content_tag(inner_tag, inner, :class => (same ? 'selected' : nil))
      end
    end

    if type != :abc
      value = (term.blank? or term.length > 1) ? term : default
      form = content_tag(:form, tag(:input, :type => :search,
               :id => 'searchbar-term', :name => 'q', :size => size,
               :value => value), :method => 'get', :id => 'searchbar-form',
               :action => <%= shell.base.path_of_with_belongsto_if_any %>)

      return form if type == :form

      cols << content_tag(inner_tag, form)
    end

    if format == :ul
      return content_tag(:ul, raw(cols.join), :class => 'searchbar')
    end

    return content_tag(:table, content_tag(:tr, raw(cols.join)),
             :class => 'searchbar')
  end
<%- end -%>
end
