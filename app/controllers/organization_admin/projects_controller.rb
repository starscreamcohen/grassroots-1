class OrganizationAdmin::ProjectsController < OrganizationAdminController
  before_action :find_organization, only: [:create]
  
  
  def new
    params[:project_id] ? @project = Project.find(params[:project_id]) : @project = Project.new(organization_id: current_user.administrated_organization.id)
    @skill = Skill.new
    @all_skills = Skill.all
  end

  def create
    if publishing_a_project?
      if publishing_a_project_draft?
        publish_draft_to_project_index
      else
        create_project_and_publish_it
      end
      flash[:notice] = "You successfully created a project"
      redirect_to project_path(@project.id)
    
    elsif saving_a_draft?
      if re_saving_a_draft?
        re_save_the_draft
      else
        create_new_draft_for_the_project
      end
      flash[:notice] = "This project has been saved as a draft"
      redirect_to new_organization_admin_project_path(project_id: @project.id)

    else
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])  
    @all_skills = Skill.all
  end

  def update
    @project = Project.find(params[:id])
    @project.update(project_params)
    flash[:success] = "You updated your project"
    redirect_to project_path(@project.id)
  end

private

  def project_params
    params.require(:project).permit(:title, :organization_id, 
      :user_id, :description, :skills, :deadline, :project_type)
  end

  def creates_a_newsfeed_item_for_the_project(project)
    @newsfeed_item = NewsfeedItem.create(user_id: current_user.id)
    project.newsfeed_items << @newsfeed_item
  end

  def find_organization
    @organization = Organization.find_by(params[:id])
  end

  def publishing_a_project_draft?
    params[:project][:id]
  end

  def re_saving_a_draft?
    params[:project][:id]
  end

  def re_save_the_draft
    @project = Project.find(params[:project][:id])
    @project.update!(project_params.merge!(causes: @organization.cause))
  end

  def publishing_a_project?
    params[:commit] == "Publish Project"
  end

  def saving_a_draft?
    params[:commit] == "Save Draft"
  end

  def create_new_draft_for_the_project
    @project = Project.new(project_params.merge!(causes: @organization.cause))
    @project.save 
    @project_draft = ProjectDraft.create(organization_id: @organization.id, project_id: @project.id)
  end

  def publish_draft_to_project_index
    @project = Project.find(params[:project][:id])
    @project.update!(project_params.merge!(causes: @organization.cause, state: "open"))
    creates_a_newsfeed_item_for_the_project(@project)
  end

  def create_project_and_publish_it
    @project = Project.new(project_params) 
    @project.save
    @project.update_columns(state: "open", causes: @organization.cause)
    creates_a_newsfeed_item_for_the_project(@project)
  end
end