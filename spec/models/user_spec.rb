require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context 'デフォルトユーザー' do
      it '正常系' do
        user = build(:user, :default)
        expect(user).to be_valid
        expect(user.errors).to be_empty
      end
      it '異常系：emailがない' do
        user_without_email = build(:user, :default, email: '')
        expect(user_without_email).to be_invalid
        expect(user_without_email.errors[:email]).to eq [I18n.t('errors.messages.blank')]
      end
      it '異常系：passwordがない' do
        user_without_password = build(:user, :default, password: '')
        expect(user_without_password).to be_invalid
        expect(user_without_password.errors[:password]).to eq [I18n.t('errors.messages.too_short', count: 3)]
      end
      it '異常系：password_confirmationがない' do
        user_without_password_confirmation = build(:user, :default, password_confirmation: '')
        expect(user_without_password_confirmation).to be_invalid
        expect(user_without_password_confirmation.errors[:password_confirmation]).to eq [I18n.t('errors.messages.confirmation', attribute: User.human_attribute_name(:password)),I18n.t('errors.messages.blank')]
      end
      it '異常系：passwordとpassword_confirmationが異なる' do
        user_with_different_passwords = build(:user, :default, password: 'password', password_confirmation: 'password_confirmation')
        expect(user_with_different_passwords).to be_invalid
        expect(user_with_different_passwords.errors[:password_confirmation]).to eq [I18n.t('errors.messages.confirmation', attribute: User.human_attribute_name(:password))]
      end
      it '異常系：passwordが3文字未満' do
        user_with_short_password = build(:user, :default, password: 'pa', password_confirmation: 'pa')
        expect(user_with_short_password).to be_invalid
        expect(user_with_short_password.errors[:password]).to eq [I18n.t('errors.messages.too_short', count: 3)]
      end
      it '異常系：email（デフォルトログイン）が既に存在する' do
        existing_user = create(:user, :default)
        new_user = build(:user, :default, email: existing_user.email)
        expect(new_user).to be_invalid
        expect(new_user.errors[:email]).to eq [I18n.t('errors.messages.taken')]
      end
      it '正常系：email（Googleログイン）が既に存在する' do
        existing_google_login_user = create(:user, :google)
        new_user = build(:user, :default, email: existing_google_login_user.email)
        expect(new_user).to be_valid
        expect(new_user.errors).to be_empty
      end
    end

    context 'Googleログインユーザー' do
      before { create(:user, :google) }
      it '正常系' do
        user = build(:user, :google)
        expect(user).to be_valid
        expect(user.errors).to be_empty
      end
      it '正常系：email（デフォルトログイン）が既に存在する' do
        existing_user = create(:user, :default)
        new_user = build(:user, :google, email: existing_user.email)
        expect(new_user).to be_valid
        expect(new_user.errors).to be_empty
      end
      it '異常系：email（Googleログイン）が既に存在する' do
        existing_google_login_user = create(:user, :google)
        new_user = build(:user, :google, email: existing_google_login_user.email)
        expect(new_user).to be_invalid
        expect(new_user.errors[:email]).to eq [I18n.t('errors.messages.taken')]
      end
    end
  end
end
