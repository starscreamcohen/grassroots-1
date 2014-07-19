class SkillsController < ApplicationController
  def create
    if adding_a_skill_to_a_project?
      to_an_existing_project_draft? ? find_the_project_with_the_draft : create_a_draft_for_the_project
      an_existing_skill? ? add_skill_to_the(@project) : create_skill_and_associate_to_the(@project)
    else
      an_existing_skill? ? add_existing_skill_to_user : add_new_skill_to_user
    end
  end

private

  def an_existing_skill?
    Skill.where(name: params[:skill][:name]) != []
  end

  def adding_a_skill_to_a_project?
    params[:commit] == "Add Skill to Project"
  end

  def to_an_existing_project_draft?
    Project.find_by(params[:project_id])
  end

  def create_a_draft_for_the_project
    @project = Project.create(organization_id: current_user.administrated_organization.id)
    @project_draft = ProjectDraft.create(organization_id: current_user.administrated_organization.id, project_id: @project.id)
  end

  def add_skill_to_the(project)
    skill = Skill.where(name: params[:skill][:name]).first
    project.skills << skill
    redirect_to new_organization_admin_project_path(project_id: @project.id)
  end

  def create_skill_and_associate_to_the(project)
    skill = Skill.create(name: params[:skill][:name])
    project.skills << skill
    redirect_to new_organization_admin_project_path(project_id: @project.id)
  end

  def find_the_project_with_the_draft
    @project = Project.find(params[:project_id])
  end

  def add_existing_skill_to_user
    skill = Skill.where(name: params[:skill][:name]).first
    current_user.skills << skill
    redirect_to :back
  end

  def add_new_skill_to_user
    skill = Skill.create(name: params[:skill][:name]) if params[:skill][:name]
    current_user.skills << skill if params[:skill][:name]
    redirect_to :back
  end
end