class InquiriesController < ApplicationController
  skip_before_action :require_login

  def new
    @inquiry = Inquiry.new
    @inquiry.email = logged_in? ? current_user.email : ''
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)
    if @inquiry.valid?
      InquiryMailer.inquiry_email(@inquiry.email, @inquiry.body).deliver_now
      redirect_to root_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :new
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:email, :body)
  end
end
