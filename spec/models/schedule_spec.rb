require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context 'デフォルト作成' do
      it '正常系' do
        schedule = build(:schedule, :default)
        expect(schedule).to be_valid
        expect(schedule.errors).to be_empty
      end
    end

    context 'Googleカレンダーからの取得' do
      it '正常系' do
        schedule = build(:schedule, :google)
        expect(schedule).to be_valid
        expect(schedule.errors).to be_empty
      end
    end
  end
end
