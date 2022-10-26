require 'rails_helper'

RSpec.describe "UserSessions", type: :system do
  describe 'ログイン前' do
    describe 'デフォルトログイン' do
      let(:user) { create(:user, :default) }

      context 'フォームの入力値が正常' do
        it 'ログインに成功する' do
          visit login_path
          fill_in 'email', with: user.email
          fill_in 'password', with: 'password'
          click_button I18n.t('defaults.login')
          expect(page).to have_content I18n.t('user_sessions.create.success')
          expect(current_path).to eq dashboards_path
        end
      end

      context 'メールアドレスが未入力' do
        it 'ログインに失敗する' do
          visit login_path
          fill_in 'email', with: ''
          fill_in 'password', with: 'password'
          click_button I18n.t('defaults.login')
          expect(page).to have_content I18n.t('user_sessions.create.fail')
          expect(page).to have_content I18n.t('user_sessions.create.error_message')
          expect(current_path).to eq login_path
        end
      end

      context 'パスワードが未入力' do
        it 'ログインに失敗する' do
          visit login_path
          fill_in 'email', with: user.email
          fill_in 'password', with: ''
          click_button I18n.t('defaults.login')
          expect(page).to have_content I18n.t('user_sessions.create.fail')
          expect(page).to have_content I18n.t('user_sessions.create.error_message')
          expect(current_path).to eq login_path
        end
      end

      context 'パスワードが異なる' do
        it 'ログインに失敗する' do
          visit login_path
          fill_in 'email', with: user.email
          fill_in 'password', with: 'different_password'
          click_button I18n.t('defaults.login')
          expect(page).to have_content I18n.t('user_sessions.create.fail')
          expect(page).to have_content I18n.t('user_sessions.create.error_message')
          expect(current_path).to eq login_path
        end
      end
    end

    describe 'Googleログイン' do
      context 'Googleログインを行う' do
        it 'ログインに成功する' do
          # あとで書く
        end
      end
    end
  end

  describe 'ログイン後' do
    context 'ログアウト' do
      it 'ログアウトに成功する' do
        user = create(:user, :default)
        login_as(user)
        find('#dropdown-icon').click
        click_button I18n.t('defaults.logout')
        expect(page).to have_content I18n.t('user_sessions.destroy.success')
        expect(current_path).to eq root_path
      end
    end
  end
end