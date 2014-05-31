require 'spec_helper'

describe ContractsController, :type => :controller do
  describe "GET new" do

    let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let(:cat) {Fabricate(:user, first_name: "Cat", user_group: "volunteer")}
    let(:dan) {Fabricate(:user, first_name: "Dan", user_group: "volunteer")}
    
    let(:logo) { Fabricate(:project, title: "need a logo", user_id: alice.id, organization_id: huggey_bear.id, state: "open")  }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }

    let(:contract1) { Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id) } 
    before do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id, accepted: true, rejected: false) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I've accepted you to join")

      get :new, contract_id: contract1.id
    end
    
    it "renders the new template for creating a request as a private message for the project administrator to review the volunteer's work" do
      expect(response).to render_template(:new)
    end

    it "sets @private_message with project administrator as recipient of message" do
      expect(assigns(:private_message)).to be_instance_of(PrivateMessage)
    end

    it "sets the recipient value in the initialized @private_message" do

      expect(assigns(:private_message).recipient).to eq(alice)
    end
  
  end

  describe "POST create" do
    let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let(:cat) {Fabricate(:user, first_name: "Cat", user_group: "volunteer")}
    let(:dan) {Fabricate(:user, first_name: "Dan", user_group: "volunteer")}
    
    let(:logo) { Fabricate(:project, title: "need a logo", user_id: alice.id, organization_id: huggey_bear.id, state: "open")  }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }

    let(:contract1) { Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id) } 

    before do
      set_current_user(alice)
      huggey_bear.update_columns(user_id: alice.id)
      ##I have no idea how to refactor the test variables like application1, application2 
      #etc...into either let statements or before do
    end

    it "renders the conversation show view" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(response).to redirect_to(conversation_path(conversation1.id))
    end
    it "creates a contract" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(Contract.count).to eq(1)
    end

    it "makes the volunteer application accepted" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(application1.reload.accepted).to eq(true)
    end

    it "makes the volunteer's application rejected status, false" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(application1.reload.rejected).to eq(false)
    end
    it "makes the other volunteer applications rejected" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

      application2 = Fabricate(:volunteer_application, applicant_id: cat.id, administrator_id: alice.id, project_id: word_press.id)
      conversation2 = Fabricate(:conversation, volunteer_application_id: application2.id)  
      message2 = Fabricate(:private_message, recipient_id: alice.id, sender_id: cat.id, conversation_id: conversation2.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

      application3 = Fabricate(:volunteer_application, applicant_id: dan.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation3 = Fabricate(:conversation, volunteer_application_id: application3.id) 
      message3 = Fabricate(:private_message, recipient_id: alice.id, sender_id: dan.id, conversation_id: conversation3.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(application2.reload.rejected).to eq(true)
      expect(application3.reload.rejected).to eq(true)
    end
    it "makes the contract active " do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(Contract.first.active).to eq(true)
    end

    it "makes the organization administrator the owner of the contract" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(Contract.first.contractor_id).to eq(alice.id)
    end
    it "makes the the applicant the volunteer of the contract" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(Contract.first.volunteer_id).to eq(bob.id)
    end
    it "associated the project with the contract" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(Contract.first.project_id).to eq(word_press.id)
    end

    it "associated the volunteer with the project" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(bob.projects).to eq([word_press])
    end

    it "associates the project with the volunteer" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(word_press.volunteers).to eq([bob])
    end

    it "moves the project's state into, in production" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(bob.projects_in_production).to eq([word_press])
    end

    it "updates the conversations contract value to the id of the contract" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(conversation1.reload.contract_id).to eq(Contract.first.id)
    end

    it "updates the conversations application value to nil" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(conversation1.reload.volunteer_application_id).to eq(nil)
    end
  end

  describe "PATCH update" do
    let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let(:cat) {Fabricate(:user, first_name: "Cat", user_group: "volunteer")}
    let(:dan) {Fabricate(:user, first_name: "Dan", user_group: "volunteer")}
    
    let(:logo) { Fabricate(:project, title: "need a logo", user_id: alice.id, organization_id: huggey_bear.id, state: "open")  }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }

    let(:contract) { Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id) } 
    let(:conversation) { Fabricate(:conversation, contract_id: contract.id) }
    let(:message1) {Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")}
    let(:message2) {Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")}

    before do
      set_current_user(alice)
      alice.update_columns(organization_id: huggey_bear.id)
    end

    context "when retracting (dropping) a contract" do
      it "renders the conversation show view" do
        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
        patch :dropping_contract, id: contract.id

        expect(response).to redirect_to(conversation_path(conversation.id))
      end

      it "sets the status of the contract, dropped_out, to true" do
        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
        patch :dropping_contract, id: contract.id
        
        expect(contract.reload.dropped_out).to eq(true)
      end

      it "sets the status of the contract, active, to false" do
        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
        patch :dropping_contract, id: contract.id
        
        expect(contract.reload.active).to eq(false)
      end

      it "automates a message to both parties" do
        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
        patch :dropping_contract, id: contract.id

        expect(conversation.private_messages.count).to eq(3)
      end

      it "clears the project of its volunteers" do
        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
        patch :dropping_contract, id: contract.id
      
        expect(word_press.volunteers).to eq([])
      end

      it "makes the volunteer still keep a record of the contract and its dropped out status" do
        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
        patch :dropping_contract, id: contract.id

        contract = Contract.find_by(volunteer_id: bob.id)

        expect(bob.contracts).to eq([contract])
        expect(contract.dropped_out).to eq(true)
        expect(contract.active).to eq(false)
      end

      it "makes the contractor still keep a record of the contract and its dropped out status" do
        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
        patch :dropping_contract, id: contract.id

        
        contract = Contract.find_by(contractor_id: alice.id)
        expect(alice.contracts).to eq([contract])
        #expect(contract.dropped_out).to eq(true)
        #expect(contract.active).to eq(false)
      end
    end
    
    before do
      set_current_user(bob)
      alice.update_columns(organization_id: huggey_bear.id)
    end

    context "when submitting work for the contractor to review" do
      it "renders the current user's inbox" do
        patch :update_contract_work_submitted, id: contract.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

        expect(response).to redirect_to(conversations_path)
      end

      it "the contract reflects that the volunteer has submitted work" do
        patch :update_contract_work_submitted, id: contract.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

        expect(contract.reload.work_submitted).to eq(true)
      end

      it "makes the volunteer send a message to the administrator" do
        patch :update_contract_work_submitted, id: contract.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}
        
        expect(bob.sent_messages.count).to eq(1)
      end

      it "starts a new conversation with the administrator" do
        patch :update_contract_work_submitted, id: contract.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}
        
        expect(alice.user_conversations.count).to eq(1)
      end

      it "associated the conversation with the contract " do
        patch :update_contract_work_submitted, id: contract.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

        conversation = Conversation.last
        expect(conversation.reload.contract_id).to eq(contract.id)
      end

      it "makes the contract reflect that the volunteer has submitted work" do
        patch :update_contract_work_submitted, id: contract.id, conversation_id: conversation.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}  

        expect(contract.reload.work_submitted).to eq(true)
      end
    end
    
    context "when completing a contract" do
      it "renders the conversation view" do
        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
        patch :contract_complete, id: contract.id

        expect(response).to redirect_to(conversation_path(conversation.id))
      end

      it "makes the contract complete" do
        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
        #conversation.update(contract_id: contract.id)
        patch :contract_complete, id: contract.id

        expect(contract.reload.complete).to eq(true)
      end
    end
  end
end