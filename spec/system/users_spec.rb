require 'rails_helper'

RSpec.describe "Users", type: :system do

  describe 'ログイン前' do
    describe 'ユーザー新規登録（デフォルトログイン）' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          visit signup_path
          fill_in 'email', with: 'sample@example.com'
          fill_in 'password', with: 'password'
          fill_in 'password_confirmation', with: 'password'
          click_button I18n.t('defaults.register')
          expect(page).to have_content I18n.t('users.create.success')
          expect(current_path).to eq dashboards_path
        end
      end

      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          visit signup_path
          fill_in 'email', with: ''
          fill_in 'password', with: 'password'
          fill_in 'password_confirmation', with: 'password'
          click_button I18n.t('defaults.register')
          expect(page).to have_content I18n.t('users.create.fail')
          expect(page).to have_content User.human_attribute_name(:email) + I18n.t('errors.messages.blank')
          expect(current_path).to eq signup_path
        end
      end

      context 'パスワードが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          visit signup_path
          fill_in 'email', with: 'sample@example.com'
          fill_in 'password', with: ''
          fill_in 'password_confirmation', with: 'password'
          click_button I18n.t('defaults.register')
          expect(page).to have_content I18n.t('users.create.fail')
          expect(page).to have_content User.human_attribute_name(:password) + I18n.t('errors.messages.too_short', count: 3)
          expect(page).to have_content User.human_attribute_name(:password_confirmation) + I18n.t('errors.messages.confirmation', attribute: User.human_attribute_name(:password))
          expect(current_path).to eq signup_path
        end
      end

      context 'パスワード確認が未入力' do
        it 'ユーザーの新規作成が失敗する' do
          visit signup_path
          fill_in 'email', with: 'sample@example.com'
          fill_in 'password', with: 'password'
          fill_in 'password_confirmation', with: ''
          click_button I18n.t('defaults.register')
          expect(page).to have_content I18n.t('users.create.fail')
          expect(page).to have_content User.human_attribute_name(:password_confirmation) + I18n.t('errors.messages.blank')
          expect(page).to have_content User.human_attribute_name(:password_confirmation) + I18n.t('errors.messages.confirmation', attribute: User.human_attribute_name(:password))
          expect(current_path).to eq signup_path
        end
      end

      context 'パスワードとパスワード確認が異なる' do
        it 'ユーザーの新規作成が失敗する' do
          visit signup_path
          fill_in 'email', with: 'sample@example.com'
          fill_in 'password', with: 'password'
          fill_in 'password_confirmation', with: 'different_password'
          click_button I18n.t('defaults.register')
          expect(page).to have_content I18n.t('users.create.fail')
          expect(page).to have_content User.human_attribute_name(:password_confirmation) + I18n.t('errors.messages.confirmation', attribute: User.human_attribute_name(:password))
          expect(current_path).to eq signup_path
        end
      end

      context 'パスワードが3文字未満' do
        it 'ユーザーの新規作成が失敗する' do
          visit signup_path
          fill_in 'email', with: 'sample@example.com'
          fill_in 'password', with: 'pa'
          fill_in 'password_confirmation', with: 'pa'
          click_button I18n.t('defaults.register')
          expect(page).to have_content I18n.t('users.create.fail')
          expect(page).to have_content User.human_attribute_name(:password) + I18n.t('errors.messages.too_short', count: 3)
          expect(current_path).to eq signup_path
        end
      end

      context 'デフォルトログインで登録済のメールアドレスを使用' do
        it 'ユーザーの新規作成が失敗する' do
          existing_user = create(:user, :default)
          visit signup_path
          fill_in 'email', with: existing_user.email
          fill_in 'password', with: 'password'
          fill_in 'password_confirmation', with: 'password'
          click_button I18n.t('defaults.register')
          expect(page).to have_content I18n.t('users.create.fail')
          expect(page).to have_content User.human_attribute_name(:email) + I18n.t('errors.messages.taken')
          expect(current_path).to eq signup_path
        end
      end

      context 'Googleログインで登録済のメールアドレスを使用' do
        it 'ユーザーの新規作成が成功する' do
          existing_google_login_user = create(:user, :google)
          visit signup_path
          fill_in 'email', with: existing_google_login_user.email
          fill_in 'password', with: 'password'
          fill_in 'password_confirmation', with: 'password'
          click_button I18n.t('defaults.register')
          expect(page).to have_content I18n.t('users.create.success')
          expect(current_path).to eq dashboards_path
        end
      end

      describe 'ユーザー新規登録（Googleログイン）' do
        context 'Googleログインを行う' do
          it 'ユーザーの新規作成が成功する' do
            # あとで書く
          end
        end
      end
    end
  end

  describe 'ログイン後' do
    let(:user) { create(:user, :default) }
    before { login_as(user) }

    context 'ユーザー新規登録' do
      it 'アクセスが失敗する' do
        visit signup_path
        expect(page).to have_content I18n.t('defaults.invalid_access')
        expect(current_path).to eq dashboards_path
      end
    end

    context 'ユーザー退会' do
      it 'ユーザーの退会処理が成功する' do
        visit user_path(user)
        click_button '削除する'
        expect(page.accept_confirm).to eq I18n.t('defaults.delete_confirmation')
        expect(page).to have_content I18n.t('users.destroy.success')
        expect(current_path).to eq root_path
      end
    end
  end
end
