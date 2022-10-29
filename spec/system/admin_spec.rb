require 'rails_helper'

RSpec.describe "Admin", type: :system do

  describe 'ログイン前' do
    context 'ユーザーが管理画面にアクセスする' do
      it 'アクセスが失敗する' do
        expect{ get '/admin' }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe 'ログイン後' do
    let(:general_user) { create(:user, :default) }
    let(:admin_user) { create(:user, :default, role: :admin) }

    context '管理権限のあるユーザーが管理画面にアクセスする' do
      it 'アクセスが成功する' do
        login_as(admin_user)
        visit admin_root_path
        expect(current_path).to eq admin_root_path
      end
    end

    context '管理権限のないユーザーが管理画面にアクセスする' do
      it 'アクセスが失敗する' do
        login_as(general_user)
        expect{ get '/admin' }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
