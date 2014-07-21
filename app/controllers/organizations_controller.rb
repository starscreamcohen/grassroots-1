class OrganizationsController < ApplicationController
  before_action :find_organization, only: [:show]
  
  def show
    @projects = @organization.organizations_projects_by_state(params[:tab])
    
    respond_to do |format|
      format.html do
      end
      format.js
    end
  end

  def index
    @organizations = Organization.all
  end

  def search
    filter = {cause: params[:cause]} if params[:cause]
    
    if filter != nil
      @results = Organization.where(filter).to_a
      @results.sort! {|x,y| x.name <=> y.name }
    else
      @results = Organization.search_by_name(params[:search_term])
    end 
  end

private

  def organization_params
    params.require(:organization).permit(:name, :date_of_incorporation, 
      :ein, :street1, :street2, :city, :state_abbreviation, :zip, :cause, 
      :contact_number, :contact_email, :mission_statement, :goal, :user_id)
  end

  def find_organization
    @organization = Organization.find(params[:id])
  end
end