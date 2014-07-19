require 'spec_helper'

feature 'creates a project draft' do 
  let!(:huggey_bears) {Fabricate(:organization, name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
      mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
      ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", 
      state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
      budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
      goal: "We want 1 out of every 5 Americans to have a huggey bear.")}

  let!(:alice) {Fabricate(:user, organization_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@huggey_bear.org", 
      interests: "Animal Rights", street1: nil, street2: nil, 
      city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
      organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")}
  
  scenario "Administrator of an organization signs in to create a project draft and add a skill to it" do
    huggey_bears.update_columns(user_id: 1)

    user_signs_in(alice)
    visit new_organization_admin_project_path

    fill_in "skill[name]", with: "Test Driven Development"
    click_button 'Add Skill to Project'

    fills_out_project_form
    click_button 'Save Draft'
    
    expect(page).to have_text("I need a word press website.")
    expect(page).to have_text("Test Driven Development")
    #expect(page).to have_text("WordPress Help")

    visit organization_path(huggey_bears)
    expect(page).to have_text("Drafts 1")
    #click_on "WordPress Help"

  end
  #scenario "Administrator of an organization signs in to create a project"

  def fills_out_project_form
    find("#project_deadline_2i").find(:xpath,"./option[contains(.,'October')]").selected?
    find("#project_deadline_3i").find(:xpath,"./option[contains(.,'15')]").selected?
    find("#project_deadline_1i").find(:xpath,"./option[contains(.,'2014')]").selected?
    fill_in "project[estimated_hours]", with: "25"
    fill_in "project[title]", with: "WordPress Help"
    fill_in "project[description]", with: "I need a word press website."
    find(:xpath, "//input[@id='project_organization_id']").set "1"
  end
end