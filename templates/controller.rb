# The code in this file implements controller class <%= controller_class_name %>Controller.

<%- if has_will_paginate? -%>
require "will_paginate"

<%- end -%>
# The <%= controller_class_name %>Controller implements the user interface for handling
# <%= class_name %> objects.

class <%= controller_class_name %>Controller < ApplicationController

  before_filter :setup_<%= file_name %>, :except => [ :index, :new, :create ]

  # Action listing all <%= table_name %>.
  #
  # Routes:
  #
  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml

  def index
  <%- if has_will_paginate? -%>
    @<%= table_name %> = <%= class_name %>.paginate(:all, :page => current_page)
  <%- else -%>
    @<%= table_name %> = <%= class_name %>.all
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
  # [:id] ID of the <%= file_name %> to display
  #
  # Routes:
  #
  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # Action displaying a form for creating a new <%= file_name %>.
  #
  # Routes:
  #
  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml

  def new
    @<%= file_name %> = <%= class_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # Action displaying an edit form for a <%= file_name %>.
  #
  # Action parameters:
  #
  # [:id] ID of the <%= file_name %> to edit
  #
  # Routes:
  #
  # GET /<%= table_name %>/1/edit

  def edit
  end

  # Action creating a new <%= file_name %>.
  #
  # Action parameters:
  #
  # [:<%= file_name %>[]] Form data
  #
  # Routes:
  #
  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml

  def create
    data = params[:<%= file_name %>].slice(<%= attributes.collect { |a|
      a.name == 'id' ? nil : ":#{a.name}" }.compact.join(', ') %>)

    @<%= file_name %> = <%= class_name %>.new(data)

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = t('<%= file_name %>.create.flash')

        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created,
                        :location => @<%= file_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors,
                        :status => :unprocessable_entity }
      end
    end
  end

  # Action updating a <%= file_name %>.
  #
  # Action parameters:
  #
  # [:id] ID of the <%= file_name %> to update
  # [:<%= file_name %>[]] Form data
  #
  # Routes:
  #
  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml

  def update
    data = params[:<%= file_name %>].slice(<%= attributes.collect { |a|
      a.name == 'id' ? nil : ":#{a.name}" }.compact.join(', ') %>)

    respond_to do |format|
      if @<%= file_name %>.update_attributes(data)
        flash[:notice] = t('<%= file_name %>.update.flash')

        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors,
                        :status => :unprocessable_entity }
      end
    end
  end

  # Action deleting a <%= file_name %>.
  #
  # Action parameters:
  #
  # [:id] ID of the <%= file_name %> to delete
  #
  # Routes:
  #
  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml

  def destroy
    @<%= file_name %>.destroy

    respond_to do |format|
      flash[:notice] = t('<%= file_name %>.destroy.flash')

      format.html { redirect_to(<%= table_name %>_url) }
      format.xml  { head :ok }
    end
  end

  protected

    # Before filter setting up @<%= file_name %> looking up a <%= file_name %>
    # needed by most actions.

    def setup_<%= file_name %>
      @<%= file_name %> = <%= class_name %>.find(params[:id])

      if @<%= file_name %>.nil?
        flash[:error] = t('<%= file_name %>.error.not_found')

        respond_to do |format|
          format.html { redirect_to(home_path) }
          format.xml  { head 404 }
        end

        return false
      end

      return true
    end
  <%- if has_will_paginate? -%>

    # Returns the current page number for pagination.

    def current_page
      return (@page ||= params[:page].blank? ? 1 : params[:page].to_i)
    end
  <%- end -%>
end
