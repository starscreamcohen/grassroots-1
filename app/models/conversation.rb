class Conversation < ActiveRecord::Base
  has_many :private_messages, -> {order('created_at ASC')}

  def sender_user_name_of_recent_message
    message = self.private_messages.last
    user = message.sender_id
    name = User.find_by(id: user)
    "#{name.first_name} #{name.last_name}"
  end

  def the_id_of_sender
    message = self.private_messages.last
    user = message.sender_id
    name = User.find_by(id: user)
    name.id
  end

  def private_message_subject
    message = self.private_messages.last
    message_subject = message.subject
  end

  def private_message_body
    message = self.private_messages.last
    message_body = message.body
  end

  def join_request
    message = self.private_messages.first
    project = Project.find_by(id: message.project_id)
    if project.users.count >= 2
      project.state == "open"
    end
  end

  def project_complete_request
    message = self.private_messages.first
    project = Project.find_by(id: message.project_id)
    if project
      project.state == "pending approval"
    end
  end

  def opportunity_drop_project
    message = self.private_messages.first
    project = Project.find_by(id: message.project_id)
    if project
      project.state == "in production"
    end
  end
end