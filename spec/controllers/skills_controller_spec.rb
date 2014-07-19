require 'spec_helper'

describe SkillsController, :type => :controller do
  describe 'POST create' do
    context "when a user adds skills to his profile" do
      let!(:alice) {Fabricate(:user, first_name: "Alice", user_group: "volunteer")}
      let!(:graphic_design) {Fabricate(:skill, name: "Graphic Design")}

      before(:each) do
        set_current_user(alice)
        request.env["HTTP_REFERER"] = "/users/1/edit" unless request.nil? or request.env.nil?
      end
      
      it "redirects back to the edit profile page" do
        post :create, skill: {name: ""}
        expect(response).to redirect_to(edit_user_path(alice))
      end
      
      it "associates a skill with the user" do
        post :create, skill: {name: "Graphic Design"}
        expect(alice.skills).to match_array([graphic_design])
      end

      it "creates a new skill if skill does not exist" do
        post :create, skill: {name: "Ruby on Rails"}
        expect(Skill.count).to eq(2)
      end
    end

    context "when a user adds required skills to a project" do
      let!(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
      let!(:huggey_bear) {Fabricate(:organization, user_id: alice.id)}
      let!(:graphic_design) {Fabricate(:skill, name: "Graphic Design")}

      before(:each) do
        set_current_user(alice)
      end

      it "creates a project" do
        post :create, skill: {name: "Ruby on Rails"}, commit: "Add Skill to Project"
        
        expect(Project.count).to eq(1)
      end

      it "creates a project draft if it creates a project" do
        post :create, skill: {name: "Ruby on Rails"}, commit: "Add Skill to Project"
        
        project = Project.first
        expect(project.project_draft).to eq(ProjectDraft.first)
      end

      it "does not create a project draft if the project has one" do
        project = Project.create(organization_id: alice.administrated_organization.id)
        ProjectDraft.create(organization_id: alice.administrated_organization.id, project_id: project.id)
        post :create, skill: {name: "Ruby on Rails"}, commit: "Add Skill to Project", project_id: project.id
        
        expect(ProjectDraft.count).to eq(1)
      end

      it "redirects back to the project creation page" do
        post :create, skill: {name: "Adobe"}, commit: "Add Skill to Project"

        expect(response).to redirect_to(new_organization_admin_project_path(project_id: Project.first.id))
      end

      it "associates a skill with the project" do
        post :create, skill: {name: "Graphic Design"}, commit: "Add Skill to Project"

        expect(assigns(:project).skills).to match_array([graphic_design])
      end

      it "creates a new skill if skill does not exist" do
        post :create, skill: {name: "Ruby on Rails"}, commit: "Add Skill to Project"
        
        expect(Skill.count).to eq(2)
      end

      it "does not create another project when adding another skill" do
        project = Project.create(organization_id: alice.administrated_organization.id)
        project.skills << graphic_design
        post :create, skill: {name: "Ruby on Rails"}, commit: "Add Skill to Project", project_id: project.id
        
        expect(Project.count).to eq(1)
      end
    end
  end
end