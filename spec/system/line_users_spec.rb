require 'rails_helper'

RSpec.describe "LineUsers", type: :system do

  describe 'ログイン後' do
    let(:user) { create(:user, :default) }
    before { login_as(user) }

    describe 'LINEユーザー登録前' do
      context 'LINEユーザー一覧' do
        before { visit line_users_path }

        it 'LINEユーザーが表示されていない' do
          expect(page).to have_content I18n.t('line_users.index.no_result')
        end

        it '自分のLINEアカウントを登録するボタンが機能する' do
          uri = URI.parse(find('#self-line-login')[:href])
          expect(uri.path).to match /\/api\/line_login\/[\w\-._]+\/login/
          token = uri.path.gsub(/\/api\/line_login\//, "").gsub(/\/login/, "")
          link_token = LinkToken.find_by(token_digest: Digest::MD5.hexdigest(token))
          expect(link_token.user_id).to eq user.id
          expect(uri.query).to eq "app_user_id=#{user.id}&self=true"
        end

        it '他人のLINEアカウントを登録するボタンが機能する' do
          uri = URI.parse(CGI.unescape(find('#other-line-login')[:href]).gsub(/.*\n/, ""))
          expect(uri.path).to match /\/api\/line_login\/[\w\-._]+\/login/
          token = uri.path.gsub(/\/api\/line_login\//, "").gsub(/\/login/, "")
          link_token = LinkToken.find_by(token_digest: Digest::MD5.hexdigest(token))
          expect(link_token.user_id).to eq user.id
          expect(uri.query).to eq "app_user_id=#{user.id}&self=false"
        end

      end
    end

    describe 'LINEユーザー登録後' do
      let!(:line_user) { create(:line_user, users: [user]) }

      context 'LINEユーザー一覧' do
        before { visit line_users_path }

        it 'LINEユーザーが表示されている' do
          expect(page).to have_content line_user.display_name
        end

        it 'LINEユーザーの削除が成功する' do
          find("#buttons-#{line_user.id}").click_button('削除')
          expect(page.accept_confirm).to eq I18n.t('defaults.delete_confirmation')
          expect(page).to have_content I18n.t('line_users.destroy.success')
          expect(current_path).to eq line_users_path
        end
      end

    end
  end
end
