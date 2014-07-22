class NewsfeedItem < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :newsfeedable, polymorphic: :true  
  has_many :comments, as: :commentable

  def self.from_users_followed_by(a_user)
    relevent_items = a_user.following_relationships.map {|leader| User.find(leader.leader_id).newsfeed_items }
    relevent_items << a_user.newsfeed_items
    relevent_items.flatten!
    relevent_items.sort_by(&:created_at).reverse
  end

  def question_categories
    question = Question.find(self.newsfeedable_id)
    question.categories.map(&:name).flatten
  end

  def answer_categories
    answer = Answer.find(self.newsfeedable_id)
    question = Question.find(answer.question_id)
    question.categories.map(&:name).flatten
  end

  def title_of_answers_question
    answer = Answer.find(self.newsfeedable_id)
    question = Question.find(answer.question_id)
    question.title
  end
end