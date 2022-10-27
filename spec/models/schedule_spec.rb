require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context 'デフォルト作成' do
      it '正常系' do
        schedule = build(:schedule, :default)
        expect(schedule).to be_valid
        expect(schedule.errors).to be_empty
      end
      it '異常系：開始日時が現在より過去の日時になっている（draft）' do
        schedule = build(:schedule, :default, start_time: 1.day.ago.in_time_zone )
        expect(schedule).to be_invalid
        expect(schedule.errors[:start_time]).to eq ["は現在より先の日時にしてください"]
      end
      it '異常系：開始日時が現在より過去の日時になっている（to_be_sent）' do
        schedule = build(:schedule, :default, start_time: 1.day.ago.in_time_zone, status: :to_be_sent )
        expect(schedule).to be_invalid
        expect(schedule.errors[:start_time]).to eq ["は現在より先の日時にしてください"]
      end
      it '正常系：開始日時が現在より過去の日時になっている（sent）' do
        schedule = build(:schedule, :default, start_time: 1.day.ago.in_time_zone, status: :sent )
        expect(schedule).to be_valid
        expect(schedule.errors).to be_empty
      end
      it '異常系：開始日時が終了日時より過去の日時になっている' do
        schedule = build(:schedule, :default, start_time: 1.day.since.in_time_zone, end_time: 1.day.since.in_time_zone - 1.hour )
        expect(schedule).to be_invalid
        expect(schedule.errors[:end_time]).to eq ["は開始日時より先の日時にしてください"]
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
