require 'rails_helper'
RSpec.describe 'LineLogin', type: :request do
  describe 'GET /api/line_login/:link_token/login' do
    let(:user) { create(:user, :default) }
    let(:base_url) { LinkToken.create_line_login_url(root_url, user) }

    context 'LINE認証画面への遷移' do
      it '本人用の正しいログインURLからLINE認証画面へ遷移する' do
        self_correct_url = base_url + '&self=true'
        get self_correct_url
        expect(response).to have_http_status(302)
        expect(response.redirect_url).to include 'https://access.line.me/oauth2/v2.1/authorize'
      end

      it '他人用の正しいログインURLからLINE認証画面へ遷移する' do
        other_correct_url = base_url + '&self=true'
        get other_correct_url
        expect(response).to have_http_status(302)
        expect(response.redirect_url).to include 'https://access.line.me/oauth2/v2.1/authorize'
      end

      it 'LinkTokenとapp_user_idが関連しないログインURLからLINE認証画面へ遷移しない' do
        wrong_app_user_id_url = base_url.gsub("app_user_id=#{user.id}", "app_user_id=#{user.id+1}") + '&self=true'
        get wrong_app_user_id_url
        expect(response).to have_http_status 302
        expect(response.redirect_url).to eq root_url
      end

      it 'app_user_idパラメータが欠けたログインURLからLINE認証画面へ遷移しない' do
        without_app_user_id_url = base_url.gsub("app_user_id=#{user.id}", "") + '&self=true'
        get without_app_user_id_url
        expect(response).to have_http_status 302
        expect(response.redirect_url).to eq root_url
      end

      it 'selfパラメータが欠けたログインURLからLINE認証画面へ遷移しない' do
        without_self_url = base_url
        get without_self_url
        expect(response).to have_http_status 302
        expect(response.redirect_url).to eq root_url
      end
    end
  end

  describe 'POST /api/line_login/callback' do

    context 'LINE認証画面後の遷移' do
      it 'LINEユーザーが保存され、ログイン状態で友だち追加画面へ遷移する（本人用）' do
      end

      it 'LINEユーザーが保存され、ログアウト状態で友だち追加画面へ遷移する（他人用）' do
      end
    end
  end
end