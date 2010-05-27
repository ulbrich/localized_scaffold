# The code in this file implements controller class <%= controller_class_name %>Controller.

<%- if has_will_paginate? -%>
require 'will_paginate'

<%- end -%>
# The <%= controller_class_name %>Controller implements the user interface for handling
# <%= class_name %> objects<% if has_belongsto? -%> of a <%= belongsto.class_name %> object<% end %>.

class <%= controller_class_name %>Controller < ApplicationController
<% if has_belongsto? -%>
  before_filter :setup_<%= belongsto.file_name %>

<% end -%>
  before_filter :setup_<%= file_name %>, :except => [ <% unless options[:singleton] %>:index, <% end %>:new, :create ]
<%- if has_searchbar? %>
  # Helper classes wrapping search term and matching chars.

  Searchbar = Struct.new(:chars, :term)
<% end -%>
<%- unless options[:singleton] %>
  # Action listing all <%= table_name %><% if has_belongsto? -%> of a certain <%= belongsto.file_name %><% end %>.
  #
<%- if has_belongsto? or has_searchbar? or has_will_paginate? -%>
  # Action parameters:
  #
<%- end -%>
<%- if has_belongsto? -%>
  # [:<%= belongsto.file_name %>_id] ID of parent <%= belongsto.file_name %>
<%- end -%>
<%- if has_searchbar? -%>
  # [:q] Chars a matching <%= file_name %> has to start with
<%- end -%>
<%- if has_will_paginate? -%>
  # [:page] Page to display (defaults to 1)
<%- end -%>
  #
  # Routes:
  #
  # GET <%= belongsto_route_prefix_if_any %>/<%= table_name %>
  # GET <%= belongsto_route_prefix_if_any %>/<%= table_name %>.xml

  def index
<%- if has_searchbar? -%>
<%- if has_belongsto? -%>
    chars = <%= class_name %>.<%= searchbar %>_chars(@<%= belongsto.file_name %>.id).collect { |i| i[0] }
<%- else -%>
    chars = <%= class_name %>.<%= searchbar %>_chars.collect { |i| i[0] }
<%- end -%>

    term = params[:q]
    term = chars.first if term.blank? or term == t('standard.cmds.search')
    term = 'a' if term.blank?

    @searchbar = Searchbar.new(chars, term)

    <%- extraargs = ":order => '#{table_name}.#{searchbar} asc',
               :conditions => ['lower(#{table_name}.#{searchbar}) like ?',
               term.downcase + '%']" -%>
<%- else -%>
    <%- extraargs = '' -%>
<%- end -%>
<%- if has_belongsto? -%>
  <%- if has_will_paginate? -%>
    @<%= table_name %> = @<%= belongsto.file_name %>.<%= table_name %>.paginate(:all, :page => current_page<%= extraargs.blank? ? '' : ", #{extraargs}" %>)
  <%- else -%>
    @<%= table_name %> = @<%= belongsto.file_name %>.<%= table_name %>.all<%= extraargs.blank? ? '' : "(#{extraargs})" %>
  <%- end -%>
<%- else -%>
  <%- if has_will_paginate? -%>
    @<%= table_name %> = <%= class_name %>.paginate(:all, :page => current_page<%= extraargs.blank? ? '' : ", #{extraargs}" %>)
  <%- else -%>
    @<%= table_name %> = <%= class_name %>.all<%= extraargs.blank? ? '' : "(#{extraargs})" %>
  <%- end -%>
<%- end -%>

    respond_to do |format|
<%- if not has_belongsto? or has_searchbar? or not embed? -%>
      format.html { redirect_to(<%= path_of_with_belongsto_if_any %>) if not params[:q].blank? and @<%= table_name %>.empty? }
<%- else -%>
      format.html { flash.keep && redirect_to(<%= belongsto.singular_name %>_path(@<%= belongsto.singular_name %>)) if @<%= table_name %>.count <= <%= class_name %>::PARENT_EMBED }
<%- end -%>
      format.xml  { render :xml => @<%= table_name %> }
      format.json { render :json => json_wrap({ :records => @<%= table_name %>,
                      :ids => @<%= table_name %>.map(&:id),
                      :count => @<%= table_name %>.count }) }
    end
  end
<%- end -%>

  # Action displaying a single <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_belongsto? -%>
  # [:<%= belongsto.file_name %>_id] ID of parent <%= belongsto.file_name %>
<%- end -%>
  # [:id] ID of the <%= file_name %> to display
  #
  # Routes:
  #
  # GET <%= belongsto_route_prefix_if_any %>/<%= table_name %>/1
  # GET <%= belongsto_route_prefix_if_any %>/<%= table_name %>/1.xml

  def show
    respond_to do |format|
<%- if generate_showview? -%>
      format.html # show.html.erb
<%- else -%>
      format.html { flash.keep && redirect_to(<%= path_of_with_belongsto_if_any(:extraargs => (has_searchbar? ? ":q => @#{file_name}.#{searchbar}.first" : nil)) %>) }
<%- end -%>
      format.xml  { render :xml => @<%= file_name %> }
      format.json { render :json => json_wrap(@<%= file_name %>) }
    end
  end

  # Action displaying a form for creating a new <%= file_name %>.
  #
<%- if has_belongsto? -%>
  # Action parameters:
  #
  # [:<%= belongsto.file_name %>_id] ID of parent <%= belongsto.file_name %>
  #
<%- end -%>
  # Routes:
  #
  # GET <%= belongsto_route_prefix_if_any %>/<%= table_name %>/new
  # GET <%= belongsto_route_prefix_if_any %>/<%= table_name %>/new.xml

  def new
  <%- if has_belongsto? -%>
    @<%= file_name %> = @<%= belongsto.file_name %>.<%= table_name %>.new
  <%- else -%>
    @<%= file_name %> = <%= class_name %>.new
  <%- end -%>

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
      format.json { render :json => json_wrap(@<%= file_name %>) }
    end
  end

  # Action displaying an edit form for a <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_belongsto? -%>
  # [:<%= belongsto.file_name %>_id] ID of parent <%= belongsto.file_name %>
<%- end -%>
  # [:id] ID of the <%= file_name %> to edit
  #
  # Routes:
  #
  # GET <%= belongsto_route_prefix_if_any %>/<%= table_name %>/1/edit

  def edit
  end

  # Action creating a new <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_belongsto? -%>
  # [:<%= belongsto.file_name %>_id] ID of parent <%= belongsto.file_name %>
<%- end -%>
  # [:<%= file_name %>[]] Form data
  #
  # Routes:
  #
  # POST <%= belongsto_route_prefix_if_any %>/<%= table_name %>
  # POST <%= belongsto_route_prefix_if_any %>/<%= table_name %>.xml

  def create
    data = params[:<%= file_name %>].slice(<%= shell.base.attributes.collect { |a|
      a.name == 'id' or (has_belongsto? and a.name == "#{belongsto.file_name}_id") ? nil : ":#{a.name}" }.compact.join(', ') %>)

  <%- if has_belongsto? -%>
    @<%= file_name %> = @<%= belongsto.file_name %>.<%= table_name %>.new(data)
  <%- else -%>
    @<%= file_name %> = <%= class_name %>.new(data)
  <%- end -%>

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = t('<%= file_name %>.create.flash')

        format.html { redirect_to(<%= path_of_with_belongsto_if_any(:method => :show) %>) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created,
                        :location => @<%= file_name %> }
        format.json { render :json => json_wrap(@<%= file_name %>) }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @<%= file_name %>.errors,
                        :status => :unprocessable_entity }
        format.json { render :json => json_wrap(@<%= file_name %>.errors),
                        :status => :unprocessable_entity }
      end
    end
  end

  # Action updating a <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_belongsto? -%>
  # [:<%= belongsto.file_name %>_id] ID of parent <%= belongsto.file_name %>
<%- end -%>
  # [:id] ID of the <%= file_name %> to update
  # [:<%= file_name %>[]] Form data
  #
  # Routes:
  #
  # PUT <%= belongsto_route_prefix_if_any %>/<%= table_name %>/1
  # PUT <%= belongsto_route_prefix_if_any %>/<%= table_name %>/1.xml

  def update
    data = params[:<%= file_name %>].slice(<%= shell.base.attributes.collect { |a|
      a.name == 'id' or (has_belongsto? and a.name == "#{belongsto.file_name}_id") ? nil : ":#{a.name}" }.compact.join(', ') %>)

    respond_to do |format|
      if @<%= file_name %>.update_attributes(data)
        flash[:notice] = t('<%= file_name %>.update.flash')

        format.html { redirect_to(<%= path_of_with_belongsto_if_any(:method => :show) %>) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @<%= file_name %>.errors,
                        :status => :unprocessable_entity }
        format.json { render :json => json_wrap(@<%= file_name %>.errors),
                        :status => :unprocessable_entity }
      end
    end
  end

  # Action deleting a <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_belongsto? -%>
  # [:<%= belongsto.file_name %>_id] ID of parent <%= belongsto.file_name %>
<%- end -%>
  # [:id] ID of the <%= file_name %> to delete
  #
  # Routes:
  #
  # DELETE <%= belongsto_route_prefix_if_any %>/<%= table_name %>/1
  # DELETE <%= belongsto_route_prefix_if_any %>/<%= table_name %>/1.xml

  def destroy
    @<%= file_name %>.destroy

    respond_to do |format|
      flash[:notice] = t('<%= file_name %>.destroy.flash')

      format.html { redirect_to(<%= path_of_with_belongsto_if_any(:extraargs => (has_searchbar? ? ":q => @#{file_name}.#{searchbar}.first" : nil)) %>) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  protected

    # Before filter setting up @<%= file_name %> needed by most actions.

    def setup_<%= file_name %>
    <%- if has_belongsto? -%>
      @<%= file_name %> = @<%= belongsto.file_name %>.<%= table_name %>.find(params[:id])
    <%- else -%>
      @<%= file_name %> = <%= class_name %>.find(params[:id])
    <%- end -%>

      if @<%= file_name %>.nil?
        flash[:error] = t('<%= file_name %>.errors.not_found')

        respond_to do |format|
          format.html { redirect_to(defined?(home_path) ? home_path : '/') }
          format.xml  { head 404 }
          format.json { head 404 }
        end

        return false
      end

      return true
    end
  <%- if has_belongsto? -%>

    # Before filter setting up "parent" belongs_to object @<%= belongsto.file_name %>
    # needed by most actions.

    def setup_<%= belongsto.file_name %>
      @<%= belongsto.file_name %> = <%= belongsto.class_name %>.find(params[:<%= belongsto.file_name %>_id])

      if @<%= belongsto.file_name %>.nil?
        flash[:error] = _('<%= belongsto.file_name %>.errors.not_found')

        respond_to do |format|
          format.html { redirect_to(defined?(home_path) ? home_path : '/') }
          format.xml  { head 404 }
          format.json { head 404 }
        end

        return false
      end
    end
  <%- end -%>
  <%- if has_will_paginate? -%>

    # Returns the current page number for pagination.

    def current_page
      return (@page ||= params[:page].blank? ? 1 : params[:page].to_i)
    end
  <%- end -%>

    # Returns a JSON version of the provided data optionally wrapped with a
    # callback method (if action parameter :jsoncallback exists) or variable
    # assignment (if action parameter :jsonvar) as expected by many toolkits.
    #
    # Parameters:
    #
    # [data] Data to marshal

    def json_wrap(data)
      if not (callback = params[:jsoncallback]).blank?
        return callback + '(' + data.to_json + ')'
      end

      if not (var = params[:jsonvar]).blank?
        return var + '=' + data.to_json
      end
      
      return data.to_json 
    end
end
