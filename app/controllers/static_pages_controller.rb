class StaticPagesController < ApplicationController
  skip_before_action :require_login

  def top
    if logged_in?
      redirect_to dashboards_path
    end
  end

  def terms
  end

  def privacy_policy
  end

  def contact
  end

  def faq
  end
end
