require 'rails_helper'

RSpec.describe GoogleLoginApiController, type: :controller do

  describe "GET #callback" do
    it "returns http success" do
      get :callback
      expect(response).to have_http_status(:success)
    end
  end

end
