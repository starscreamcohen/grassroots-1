require 'spec_helper'

describe ConversationsController, :type => :controller do
    let(:alice) { Fabricate(:user, first_name: "Alice") }
    let(:bob) { Fabricate(:user, first_name: "Bob") }
    let(:cat) { Fabricate(:user, first_name: "Cat") }
    
    before do
      session[:user_id] = alice.id
    end

  describe "GET index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
    
    it "shows a conversation if current user receives a sent message" do
      conversation1 = Fabricate(:conversation)
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "OK great. when can you start?") 
      get :index

      expect(alice.user_conversations).to match_array([conversation1])
    end

    it "sets the @conversations" do
      get :index

      expect(assigns(:conversations)).to eq(alice.user_conversations)
    end
  end
  
  describe "GET show" do
    it "it renders the show template" do
      conversation1 = Fabricate(:conversation)
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "OK great. when can you start?") 
      get :show, id: conversation1.id

      expect(response).to render_template(:show)
    end
    it "sets the @messages" do
      conversation1 = Fabricate(:conversation)
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "OK great. when can you start?") 
      get :show, id: conversation1.id

      expect(assigns(:messages)).to be_instance_of(Conversation)
    end

    it "shows a received private message" do
      conversation1 = Fabricate(:conversation)
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      get :show, id: conversation1.id
      expect(conversation1.private_messages).to eq([message1])
    end

    it "shows the private messages of the conversation" do
      conversation1 = Fabricate(:conversation)
      message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "OK great. when can you start?") 
      get :show, id: conversation1.id

      expect(conversation1.private_messages).to eq([message1, message2])
    end

    context "when replying to a message" do
      it "sets the @private_message to new" do
        conversation1 = Fabricate(:conversation)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        get :show, id: conversation1.id

        expect(assigns(:private_message)).to be_a PrivateMessage
      end

      it "sets the recipient value" do
        conversation1 = Fabricate(:conversation)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        get :show, id: conversation1.id

        expect(assigns(:private_message).recipient).to eq(bob)
      end
      it "sets the sender value" do
        conversation1 = Fabricate(:conversation)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        get :show, id: conversation1.id

        expect(assigns(:private_message).sender).to eq(alice)
      end
      it "sets the subject line with the value of the message title with Project Request: the message's title" do
        conversation1 = Fabricate(:conversation)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        get :show, id: conversation1.id

        expect(assigns(:private_message).subject).to eq("Please let me join your project")
      end

      it "sets the conversation id of the sent message" do
        conversation1 = Fabricate(:conversation)
        message1 = Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "OK great. when can you start?") 
        get :show, id: conversation1.id

        expect(assigns(:private_message).conversation).to eq(conversation1)
      end
      
      it "shows the conversation between the sender and the recipient"
      context "when its a join request" 
        it "shows a an option to accept the join request"
        it "shows an option to reject the join request"
        it "shows an option to reply to the private message"
      ##when a join request is accepted, all other join requests are rejected
    end
  end

  describe "POST accept" do
    let(:alice) { Fabricate(:organization_administrator, organization_id: nil, first_name: "Alice") }
    let(:bob) { Fabricate(:user, first_name: "Bob") }
    let(:elena) { Fabricate(:user, first_name: "Elena") }
    let(:dan) { Fabricate(:user, first_name: "Dan")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }
    let(:conversation1) { Fabricate(:conversation) }
    let(:conversation2) { Fabricate(:conversation) }
    let(:conversation3) { Fabricate(:conversation) }
    let(:message1) { Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", project_id: word_press.id) }
    let(:message2) { Fabricate(:private_message, recipient_id: alice.id, sender_id: elena.id, conversation_id: conversation2.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", project_id: word_press.id) }
    let(:message3) { Fabricate(:private_message, recipient_id: alice.id, sender_id: dan.id, conversation_id: conversation3.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", project_id: word_press.id) }
    
    before do
      conversation1.private_messages << message1
      conversation2.private_messages << message2
      conversation3.private_messages << message3
      word_press.users << alice
      word_press.users << bob
      word_press.users << elena
      word_press.users << dan
    end

    it "redirects the current user to the conversation so that the user can reply to the freelancer" do
      post :accept, conversation_id: conversation1.id
      expect(response).to redirect_to conversation_path(conversation1.id)
    end

    it "unassociates all unaccepted users who have sent a project request" do
      post :accept, conversation_id: conversation1.id
      expect(word_press.reload.users).not_to eq([alice, bob, elena, dan])
    end

    it "associates only the sender and the current user of the conversation with the project" do
      post :accept, conversation_id: conversation1.id
      expect(word_press.reload.users).to eq([alice, bob])
    end

    it "sets all the private messages' project ids to nil except the one associated with the accepted project" do
      post :accept, conversation_id: conversation1.id

      expect(message1.reload.project_id).to eq(1)
      expect(message2.reload.project_id).to eq(nil)
      expect(message3.reload.project_id).to eq(nil)
    end

    it "sets the project's state from open to in production" do
      post :accept, conversation_id: conversation1.id

      expect(word_press.reload.state).to eq("in production")
    end
  end

  describe "POST completed" do
    let(:alice) { Fabricate(:organization_administrator, organization_id: nil, first_name: "Alice") }
    let(:bob) { Fabricate(:user, first_name: "Bob") }
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "in production") }
    let(:conversation1) { Fabricate(:conversation) }
    let(:message1) { Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Project Completed: word press website", body: "I finished this project", project_id: word_press.id) }

    before do
      conversation1.private_messages << message1
      word_press.users << bob
    end

    it "redirects the current user to the conversation so that the user can reply to the freelancer" do
      post :completed, conversation_id: conversation1.id

      expect(response).to redirect_to conversation_path(conversation1.id)
    end
    it "sets the project's state from in production to completed" do
      post :completed, conversation_id: conversation1.id

      expect(word_press.reload.state).to eq("completed")
    end

    it "flashes a message about accepting a completed project" do
      post :completed, conversation_id: conversation1.id

      expect(flash[:success]).to eq("Please write to the volunteer to let the volunteer know that the project is complete")
    end
  end

  describe "POST drop" do
    let(:alice) { Fabricate(:organization_administrator, organization_id: nil, first_name: "Alice") }
    let(:bob) { Fabricate(:user, first_name: "Bob") }
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }
    let(:conversation1) { Fabricate(:conversation) }
    
    
    let(:message1) { Fabricate(:private_message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", project_id: word_press.id) }
    
    before do
      conversation1.private_messages << message1
      word_press.users << alice
      word_press.users << bob
    end

    it "redirects the current user to the thread of the conversation after dissacotiating" do
      word_press.update_columns(state: "in production")
      post :drop, conversation_id: conversation1.id

      expect(response).to redirect_to(conversation_path(conversation1.id))
    end

    it "disassociates the freelancer from the project" do
      word_press.update_columns(state: "in production")
      post :drop, conversation_id: conversation1.id

      expect(bob.projects).to eq([])
    end

    it "moves the project from in production to open" do
      word_press.update_columns(state: "in production")
      post :drop, conversation_id: conversation1.id

      expect(word_press.reload.state).to eq("open")
    end
    it "automated message within the same message thread stating that the other user has dropped the project" do
      message2 = Fabricate(:private_message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "you are accepted", project_id: word_press.id)
      post :drop, conversation_id: conversation1.id

      expect(conversation1.private_messages.count).to eq(3)
    end
  end
end