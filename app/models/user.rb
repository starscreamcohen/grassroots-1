class User < ActiveRecord::Base

  has_secure_password validations: false
  belongs_to :organization
  has_one :administrated_organization, foreign_key: 'user_id', class_name: 'Organization'
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, -> {order('created_at DESC')}, class_name: 'Message', foreign_key: 'recipient_id'
  has_many :conversations, through: :received_messages
  
  has_many :administrated_projects, through: :administrated_organization, source: :projects

  has_many :volunteer_requests,  class_name: 'VolunteerApplication', foreign_key: 'administrator_id'
  has_many :projects, through: :volunteer_applications, source: :administrator
  has_many :delegated_projects, class_name: "Contract", foreign_key: 'contractor_id'
  has_many :projects, through: :contracts, source: :contractor
  
  has_many :requests_to_volunteer, class_name: 'VolunteerApplication', foreign_key: 'applicant_id'
  has_many :projects, through: :volunteer_applications, source: :applicant
  has_many :assignments, class_name: "Contract", foreign_key: 'volunteer_id'
  has_many :projects, through: :contracts, source: :volunteer

  has_many :accomplishments
  has_many :badges, through: :accomplishments

  has_many :following_relationships, class_name: 'Relationship', foreign_key: :follower_id

  has_many :newsfeed_items

  has_many :questions
  has_many :votes
  has_many :comments
  has_many :answers

  has_many :talents
  has_many :skills, through: :talents

  validates_presence_of :email, :password, :first_name, :last_name, :user_group
  validates_uniqueness_of :email

  before_create :generate_token

  has_attachment :avatar, accept: [:jpg, :png, :gif]

  def open_applications
    requests_to_volunteer.where(accepted: nil, rejected: nil).to_a
  end

  def completed_projects  
    contracts_reflecting_completed_work = assignments.where(active: false, complete: true).to_a
    contracts_reflecting_completed_work.map { |member| Project.find(member.project_id)}.sort
  end

  def submitted_work
    contracts_reflecting_work_being_submitted = Contract.where(volunteer_id: self.id, active: true, work_submitted: true).to_a
    contracts_reflecting_work_being_submitted.map {|member| Project.find(member.project_id)}.sort
  end

  def projects_in_production
    contracts_reflecting_work_in_production = Contract.where(volunteer_id: self.id, active: true, work_submitted: false).to_a
    contracts_reflecting_work_in_production.map {|member| Project.find(member.project_id)}.sort
  end

  def organization_name_box
    organization.try(:name)
  end

  def organization_name_box=(name)
    self.organization = Organization.find_by_name(name) if name.present?
  end

  def messages
    messages = self.sent_messages + self.received_messages
    messages.sort!
  end

  def inbox
    all_conversations = self.conversations
    all_conversations.sort! {|a, b| a.updated_at <=> b.updated_at}
  end

  def only_conversations
    self.conversations.where(volunteer_application_id: nil, contract_id: nil).to_a
  end

  def only_conversations_about_work
    self.conversations.where(contract_id: true).to_a + self.conversations.where(volunteer_application_id: true).to_a
  end

  def organization_name
    organization.name
  end

  def projects_with_open_applications
    open_applications.map {|member| Project.find(member.project_id)}
  end

  def drop_contract(agreement)
    agreement.update_columns(volunteer_id: nil, active: nil)
  end

  def generate_token
    self.new_password_token = SecureRandom.urlsafe_base64
  end

  def update_profile_progress
    profile_completeness = [self.email, self.first_name, self.last_name, self.contact_reason, self.state_abbreviation, self.city, self.bio, self.position]
    progress = 0
    profile_completeness.each {|field| progress += 1 unless field.nil? || field == ""}
    entirety = progress * 100
    self.profile_progress_status = entirety / profile_completeness.count
  end

  def awarded?(badge)
    self.badges.where(name: badge.name).present?
  end

  def follows?(another_user)
    self.following_relationships.map(&:leader).include?(another_user)
  end

  def can_follow?(another_user)
    # '!', reads like, unless
    !(self.follows?(another_user) || self == another_user)
  end

  def follow!(another_user)
    self.following_relationships.create!(leader_id: another_user.id)
    relationship = Relationship.where(leader_id: another_user, follower_id: self.id).first
    newsfeed_item = NewsfeedItem.create(user_id: self.id)
    relationship.newsfeed_items << newsfeed_item
  end

  def users_projects_by_state(clicked_tab)
    if clicked_tab == "open"
      self.projects_with_open_applications
    elsif clicked_tab == "in production"
      self.projects_in_production
    elsif clicked_tab == "submitted work"
      self.submitted_work
    else
      self.completed_projects
    end
  end
end