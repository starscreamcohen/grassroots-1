class UsersController < ApplicationController
  before_action :find_user, only: [:show]

  def index
    @users = User.all
  end

  def show
    @projects = @user.users_projects_by_state(params[:tab])

    @relationships = @user.following_relationships
    @following_relationship = Relationship.where(follower: current_user, leader: @user).first
    respond_to do |format|
      format.html do
      end
      format.js
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      AppMailer.delay.send_welcome_email(@user.id)
      session[:user_id] = @user.id
      redirect_to user_path(@user.id)
    else
      flash[:notice] = "Please try again."
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    @skill = Skill.new
    @all_skills = Skill.all
  end

  def update
    @user = User.find(params[:id])
    organization = Organization.find_by(name: params[:user][:organization_name_box])
    if an_unaffiliated_nonprofit_user_updates_profile?(organization)
      @user.update_columns(user_params.merge!(organization_administrator: true))
      uploading_profile_avatar?
      earns_profile_completion_badge?
      redirect_to new_organization_admin_organization_path
    elsif a_nonprofit_staff_member_updates_profile?(organization)
      @user.update_columns(user_params)
      uploading_profile_avatar?
      earns_profile_completion_badge?
      flash[:notice] = "You have updated your profile successfully."
      redirect_to user_path(@user.id)
    elsif a_volunteer_updates_profile?
      @user.update_columns(user_params)
      uploading_profile_avatar?
      earns_profile_completion_badge?
      flash[:notice] = "You have updated your profile successfully."
      redirect_to user_path(@user.id)
    else
      flash[:error] = "Please try again."
      render :edit
    end
  end

  def remove
    user = User.find(params[:id])
    organization = Organization.find(user.organization_id)
    user.update_columns(organization_id: nil)
    redirect_to organization_path(organization.id)
  end

  def search
    @results = User.where(talent_type: params[:talent_type]) if params[:talent_type]
  end

private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, 
      :organization_id, :bio, :interests, :position, :user_group, 
      :contact_reason, :state_abbreviation, :city)
  end

  def uploading_profile_avatar?
    if params[:user][:avatar]
      @user.avatar = params[:user][:avatar]
      @user.avatar.save
    end
  end

  def an_unaffiliated_nonprofit_user_updates_profile?(organization)
    organization.nil? && current_user.user_group == "nonprofit"
  end
 
  def a_nonprofit_staff_member_updates_profile?(organization)
    current_user.user_group == "nonprofit" && organization
  end
 
  def a_volunteer_updates_profile?
    current_user.user_group == "volunteer"
  end

  def earns_profile_completion_badge?
    if @user.update_profile_progress == 100
      badge = Badge.find_by(name: "100% User Profile Completion")
      @user.badges << badge unless @user.awarded?(badge)
      @newsfeed_item = NewsfeedItem.create(user_id: current_user.id)
      badge.newsfeed_items << @newsfeed_item
    end
  end

  def find_user
    @user = User.find(params[:id])
  end
end