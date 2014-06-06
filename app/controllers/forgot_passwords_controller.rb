class ForgotPasswordsController < ApplicationController
  def create
    user = User.where(email: params[:email]).first
    if user
      AppMailer.delay.send_forgot_password(user.id)
      redirect_to forgot_password_confirmation_path
    else
      flash[:error] = params[:email].blank? ? "Email can not be blank." : "There is no user with that email in the system."
      redirect_to forgot_password_path
    end
  end
end 