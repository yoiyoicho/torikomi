require 'rails_helper'

RSpec.describe LineLoginApiController, type: :controller do

  describe "GET #callback" do
    it "returns http success" do
      get :callback
      expect(response).to have_http_status(:success)
    end
  end

end
