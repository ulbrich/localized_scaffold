# The code in this file implements helper class <%= class_name %>Helper.

# Class <%= class_name %>Helper provides helpers available in all views of
# the <%= class_name %>Controller.

module <%= class_name %>Helper
<%- if shell.base.has_searchbar? -%>

  # Returns HTML for a searchbar with A B C etc. to pick and a small form
  # for searching a <%= shell.base.searchbar %>.
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
