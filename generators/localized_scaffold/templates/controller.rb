# The code in this file implements controller class <%= controller_class_name %>Controller.

<%- if has_will_paginate? -%>
require 'will_paginate'

<%- end -%>
# The <%= controller_class_name %>Controller implements the user interface for handling
# <%= class_name %> objects<% if has_parent? -%> of a <%= parent.class_name %> object<% end %>.

class <%= controller_class_name %>Controller < ApplicationController

<% if has_parent? -%>
  before_filter :setup_<%= parent.file_name %>

<% end -%>
  before_filter :setup_<%= file_name %>, :except => [ :index, :new, :create ]

  # Action listing all <%= table_name %><% if has_parent? -%> of a certain <%= parent.file_name %><% end %>.
  #
<%- if has_parent? -%>
  # Action parameters:
  #
  # [:<%= parent.file_name %>_id] ID of parent <%= parent.file_name %>
  #
<%- end -%>
  # Routes:
  #
  # GET <%= parent_route_prefix_if_any %>/<%= table_name %>
  # GET <%= parent_route_prefix_if_any %>/<%= table_name %>.xml

  def index
<%- if has_parent? -%>
  <%- if has_will_paginate? -%>
    @<%= table_name %> = @<%= parent.file_name %>.<%= table_name %>.paginate(:all, :page => current_page)
  <%- else -%>
    @<%= table_name %> = @<%= parent.file_name %>.<%= table_name %>.all
  <%- end -%>
<%- else -%>
  <%- if has_will_paginate? -%>
    @<%= table_name %> = <%= class_name %>.paginate(:all, :page => current_page)
  <%- else -%>
    @<%= table_name %> = <%= class_name %>.all
  <%- end -%>
<%- end -%>

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= table_name %> }
    end
  end

  # Action displaying a single <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_parent? -%>
  # [:<%= parent.file_name %>_id] ID of parent <%= parent.file_name %>
<%- end -%>
  # [:id] ID of the <%= file_name %> to display
  #
  # Routes:
  #
  # GET <%= parent_route_prefix_if_any %>/<%= table_name %>/1
  # GET <%= parent_route_prefix_if_any %>/<%= table_name %>/1.xml

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # Action displaying a form for creating a new <%= file_name %>.
  #
<%- if has_parent? -%>
  # Action parameters:
  #
  # [:<%= parent.file_name %>_id] ID of parent <%= parent.file_name %>
  #
<%- end -%>
  # Routes:
  #
  # GET <%= parent_route_prefix_if_any %>/<%= table_name %>/new
  # GET <%= parent_route_prefix_if_any %>/<%= table_name %>/new.xml

  def new
  <%- if has_parent? -%>
    @<%= file_name %> = @<%= parent.file_name %>.<%= table_name %>.new
  <%- else -%>
    @<%= file_name %> = <%= class_name %>.new
  <%- end -%>

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # Action displaying an edit form for a <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_parent? -%>
  # [:<%= parent.file_name %>_id] ID of parent <%= parent.file_name %>
<%- end -%>
  # [:id] ID of the <%= file_name %> to edit
  #
  # Routes:
  #
  # GET <%= parent_route_prefix_if_any %>/<%= table_name %>/1/edit

  def edit
  end

  # Action creating a new <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_parent? -%>
  # [:<%= parent.file_name %>_id] ID of parent <%= parent.file_name %>
<%- end -%>
  # [:<%= file_name %>[]] Form data
  #
  # Routes:
  #
  # POST <%= parent_route_prefix_if_any %>/<%= table_name %>
  # POST <%= parent_route_prefix_if_any %>/<%= table_name %>.xml

  def create
    data = params[:<%= file_name %>].slice(<%= attributes.collect { |a|
      a.name == 'id' or (has_parent? and a.name == "#{parent.file_name}_id") ? nil : ":#{a.name}" }.compact.join(', ') %>)

  <%- if has_parent? -%>
    @<%= file_name %> = @<%= parent.file_name %>.<%= table_name %>.new(data)
  <%- else -%>
    @<%= file_name %> = <%= class_name %>.new(data)
  <%- end -%>

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = t('<%= file_name %>.create.flash')

        format.html { redirect_to(<%= path_of_with_parent_if_any(:show) %>) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created,
                        :location => @<%= file_name %> }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @<%= file_name %>.errors,
                        :status => :unprocessable_entity }
      end
    end
  end

  # Action updating a <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_parent? -%>
  # [:<%= parent.file_name %>_id] ID of parent <%= parent.file_name %>
<%- end -%>
  # [:id] ID of the <%= file_name %> to update
  # [:<%= file_name %>[]] Form data
  #
  # Routes:
  #
  # PUT <%= parent_route_prefix_if_any %>/<%= table_name %>/1
  # PUT <%= parent_route_prefix_if_any %>/<%= table_name %>/1.xml

  def update
    data = params[:<%= file_name %>].slice(<%= attributes.collect { |a|
      a.name == 'id' or (has_parent? and a.name == "#{parent.file_name}_id") ? nil : ":#{a.name}" }.compact.join(', ') %>)

    respond_to do |format|
      if @<%= file_name %>.update_attributes(data)
        flash[:notice] = t('<%= file_name %>.update.flash')

        format.html { redirect_to(<%= path_of_with_parent_if_any(:show) %>) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @<%= file_name %>.errors,
                        :status => :unprocessable_entity }
      end
    end
  end

  # Action deleting a <%= file_name %>.
  #
  # Action parameters:
  #
<%- if has_parent? -%>
  # [:<%= parent.file_name %>_id] ID of parent <%= parent.file_name %>
<%- end -%>
  # [:id] ID of the <%= file_name %> to delete
  #
  # Routes:
  #
  # DELETE <%= parent_route_prefix_if_any %>/<%= table_name %>/1
  # DELETE <%= parent_route_prefix_if_any %>/<%= table_name %>/1.xml

  def destroy
    @<%= file_name %>.destroy

    respond_to do |format|
      flash[:notice] = t('<%= file_name %>.destroy.flash')

      format.html { redirect_to(<%= path_of_with_parent_if_any %>) }
      format.xml  { head :ok }
    end
  end

  protected

    # Before filter setting up @<%= file_name %> needed by most actions.

    def setup_<%= file_name %>
    <%- if has_parent? -%>
      @<%= file_name %> = @<%= parent.file_name %>.<%= table_name %>.find(params[:id])
    <%- else -%>
      @<%= file_name %> = <%= class_name %>.find(params[:id])
    <%- end -%>

      if @<%= file_name %>.nil?
        flash[:error] = t('<%= file_name %>.errors.not_found')

        respond_to do |format|
          format.html { redirect_to(defined?(home_path) ? home_path : '/') }
          format.xml  { head 404 }
        end

        return false
      end

      return true
    end
  <%- if has_parent? -%>

    # Before filter setting up parent object @<%= parent.file_name %> needed
    # by most actions.

    def setup_<%= parent.file_name %>
      @<%= parent.file_name %> = <%= parent.class_name %>.find(params[:<%= parent.file_name %>_id])

      if @<%= parent.file_name %>.nil?
        flash[:error] = _('<%= parent.file_name %>.errors.not_found')

        respond_to do |format|
          format.html { redirect_to(defined?(home_path) ? home_path : '/') }
          format.xml  { head 404 }
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
end
