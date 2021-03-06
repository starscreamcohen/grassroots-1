require 'spec_helper'

describe Organization do
  it { should belong_to(:organization_administrator)}
  it { should have_many(:projects)}
  it { should have_many(:users)}

  let(:huggey_bear) {Fabricate(:organization)}
  let(:amnesty) {Fabricate(:organization)}
  let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
  let(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
  let(:cat) {Fabricate(:organization_administrator, first_name: "Cat", user_group: "nonprofit")}

  let(:logo) {Fabricate(:project, title: "need a logo", user_id: cat.id, organization_id: amnesty.id)  }
  let(:word_press) {Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id) }


  describe "#organization_administrator" do
    it "should return the administrator of the organization" do
      huggey_bears = Fabricate(:organization)
      alice = Fabricate(:organization_administrator, organization: huggey_bears, user_group: "nonprofit")
      huggey_bears.organization_administrator = alice
      expect(huggey_bears.organization_administrator).to eq(alice)
    end
  end

  describe "#open_projects" do
    before do
      huggey_bear.update_columns(user_id: alice.id)
      amnesty.update_columns(user_id: cat.id)
    end

    it "returns the organization's open projects" do
      
      accounting = Fabricate(:project, title: "didn't do my taxes", user_id: cat.id, organization_id: amnesty.id)
      grant_writing = Fabricate(:project, title: "need Grants", user_id: alice.id, organization_id: huggey_bear.id)
      professional_site = Fabricate(:project, title: "need a site", user_id: alice.id, organization_id: huggey_bear.id, state: "open")

      contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id)
      contract2 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: false, incomplete: true, project_id: logo.id)
      contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: nil, project_id: accounting.id)
      contract4 = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: grant_writing.id, work_submitted: true)

      expect(huggey_bear.open_projects).to eq([professional_site])
    end
  end

  describe "#projects_with_work_submitted" do

    before do
      huggey_bear.update_columns(user_id: alice.id)
      amnesty.update_columns(user_id: cat.id)
    end

    it "returns the organization's projects that have received submitted work for the administrator to review" do
      accounting = Fabricate(:project, title: "didn't do my taxes", user_id: cat.id, organization_id: amnesty.id)

      contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
      contract2 = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: logo.id, work_submitted: true)
      contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: true, project_id: accounting.id, work_submitted: false)
      
      expect(huggey_bear.projects_with_work_submitted).to eq([word_press, logo])
    end
  end

  describe "#completed_projects" do

    before do
      huggey_bear.update_columns(user_id: alice.id)
      amnesty.update_columns(user_id: cat.id)
    end

    it "returns the organization's projects with contracts completed" do
      
      accounting = Fabricate(:project, title: "didn't do my taxes", user_id: cat.id, organization_id: amnesty.id)

      contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: false, project_id: word_press.id, work_submitted: true, complete: true, incomplete: false)
      contract2 = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: false, project_id: logo.id, work_submitted: true, complete: true, incomplete: false)
      contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: true, project_id: accounting.id, work_submitted: false)

      expect(huggey_bear.completed_projects).to eq([word_press, logo])
    end
  end

  describe "#unfinished_projects" do

    before do
      huggey_bear.update_columns(user_id: alice.id)
      amnesty.update_columns(user_id: cat.id)
    end

    it "returns the organization's unfinished projects through invompleted projects" do
      accounting = Fabricate(:project, title: "didn't do my taxes", user_id: cat.id, organization_id: amnesty.id)

      contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: false, project_id: word_press.id, work_submitted: nil, complete: nil, incomplete: true)
      contract2 = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: false, project_id: logo.id, work_submitted: nil, complete: nil, incomplete: true)
      contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: true, project_id: accounting.id, work_submitted: false)

      expect(huggey_bear.unfinished_projects).to eq([word_press, logo])
    end
  end

  describe "#in_production_projects" do

    before do
      huggey_bear.update_columns(user_id: alice.id)
      amnesty.update_columns(user_id: cat.id)
    end

    it "returns all projects that have active contracts with no work submitted" do
      
      accounting = Fabricate(:project, title: "didn't do my taxes", user_id: cat.id, organization_id: amnesty.id)
      grant_writing = Fabricate(:project, title: "need Grants", user_id: alice.id, organization_id: huggey_bear.id)
      professional_site = Fabricate(:project, title: "need a site", user_id: alice.id, organization_id: huggey_bear.id)

      contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: false)
      contract2 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: logo.id, work_submitted: false)
      contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: nil, project_id: accounting.id)
      contract4 = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: grant_writing.id, work_submitted: true)

      expect(huggey_bear.in_production_projects).to eq([word_press, logo])
    end
  end

  describe "#expired_projects" do

    before do
      huggey_bear.update_columns(user_id: alice.id)
    end

    it "returns all projects that have active contracts with no work submitted" do
      
      accounting = Fabricate(:project, title: "didn't do my taxes", organization_id: huggey_bear.id, deadline: Date.today + 1.month)
      grant_writing = Fabricate(:project, title: "need Grants", organization_id: huggey_bear.id, deadline: Date.yesterday)
      word_press = Fabricate(:project, title: "word press website", organization_id: huggey_bear.id, deadline: 2.day.ago)

      #contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: false)
      #contract2 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: nil, project_id: accounting.id)
      #contract3 = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: grant_writing.id, work_submitted: true)

      expect(huggey_bear.reload.expired_projects).to eq([grant_writing, word_press])
    end
  end

  describe ".search_by_name" do
    let!(:huggey_bears) {Fabricate(:organization, name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
      mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
      ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", 
      state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
      budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
      goal: "We want 1 out of every 5 Americans to have a huggey bear.")}

    let!(:amnesty_international) {Fabricate(:organization, name: "Amnesty International", cause: "Human Rights", ruling_year: 1912,
      mission_statement: "We want to see human rights spread across the globe -- chyea.", guidestar_membership: nil, 
      ein: "987931299-1", street1: "3293 Dunnit Hill", street2: nil, city: "New York", 
      state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
      budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
      goal: "Every year we want at least one thousand human rights activists released from prisons around the world.")}

    let!(:global_giving) {Fabricate(:organization, name: "Global Giving", cause: "Social Good", ruling_year: 2000, 
      mission_statement: "We make it rain on Nonprofits, erreday", guidestar_membership: nil, 
      ein: "222222222-2", street1: "2222 Rick Ross", street2: nil, city: "DC", 
      state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
      budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
      goal: "We want each of our nonprofit partners to raise at least $ 5,000.00 from our platform a year.")}

    let!(:the_bears) {Fabricate(:organization, name: "The Bears")}

    it "should return an empty array if the user submits no parameters" do
      expect(Organization.search_by_name("")).to eq([])
    end

    it "should return an empty array if it finds no organizations" do
      expect(Organization.search_by_name("red cross")).to eq([])
    end

    it "should return an array of one organizations if it is an exact match" do
      expect(Organization.search_by_name("Global Giving")).to eq([global_giving])
    end

    it "should return an array of one organizations for a partial match" do 
      expect(Organization.search_by_name("glo")).to eq([global_giving])
    end
    
    it "should return an array of all matches oredered by created_at" do
      expect(Organization.search_by_name("bear")).to eq([huggey_bears, the_bears])
    end
  end

  describe "#organizations_projects_by_state" do
    before do
      huggey_bear.update_columns(user_id: alice.id)
      amnesty.update_columns(user_id: cat.id)
    end

    let!(:accounting) {Fabricate(:project, title: "didn't do my taxes", organization_id: amnesty.id)}
    let!(:professional_site) {Fabricate(:project, title: "need a site", organization_id: huggey_bear.id, state: "open")}
    let!(:professional_logo) {Fabricate(:project, title: "need a logo", organization_id: huggey_bear.id, state: "open")}
    let!(:business_plan) {Fabricate(:project, title: "need a business plan", organization_id: huggey_bear.id)}
    let!(:word_press_site) {Fabricate(:project, title: "need a word press site", organization_id: huggey_bear.id)}
    let!(:logo) {Fabricate(:project, title: "need a snazzy logo", organization_id: huggey_bear.id)}
    let!(:accounting_2) {Fabricate(:project, title: "need my taxes done", organization_id: huggey_bear.id, deadline: 2.days.ago)}

    let!(:contract1) {Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id)}
    let!(:contract2) {Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: false, incomplete: true, project_id: logo.id)}
    let!(:contract3) {Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, work_submitted: false, project_id: business_plan.id)}
    let!(:contract4) {Fabricate(:contract, contractor_id: alice.id, active: false, work_submitted: true, complete: true, incomplete: false, project_id: word_press_site.id)}

    it "should return an array of projects that are open" do
      parameters = {tab: "open"}

      expect(huggey_bear.organizations_projects_by_state(parameters[:tab])).to eq([professional_site, professional_logo])
    end

    it "should return an array of projects that are in production" do
      parameters = {tab: "in production"}
      
      expect(huggey_bear.organizations_projects_by_state(parameters[:tab])).to eq([business_plan])
    end

    it "should return an array of projects that have completion requests" do
      parameters = {tab: "completed"}
      
      expect(huggey_bear.organizations_projects_by_state(parameters[:tab])).to eq([word_press_site])
    end

    it "should return an array of projects that are unfinished" do
      parameters = {tab: "unfinished"}
      
      expect(huggey_bear.organizations_projects_by_state(parameters[:tab])).to eq([logo])
    end
    it "should return an array of projects that are expired" do
      parameters = {tab: "expired"}

      expect(huggey_bear.organizations_projects_by_state(parameters[:tab])).to eq([accounting_2])
    end

    it "should return an array of drafts" do
      parameters = {tab: "drafts"}

      project1 = Fabricate(:project)
      project2 = Fabricate(:project)

      draft1 = ProjectDraft.create(organization_id: alice.administrated_organization.id, project_id: project1.id)
      draft2 = ProjectDraft.create(organization_id: alice.administrated_organization.id, project_id: project2.id)

      expect(huggey_bear.organizations_projects_by_state(parameters[:tab])).to eq([draft1, draft2])
    end
  end
end