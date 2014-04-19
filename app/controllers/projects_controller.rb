class ProjectsController < ApplicationController
  before_action :current_user

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      flash[:notice] = "You successfully created a project"
      redirect_to organization_path(current_user.organization.id)
    else
      render :new
    end
  end

private

  def project_params
    params.require(:project).permit(:title, :organization_id, :user_id, :description, :skills, :deadline)
  end
end