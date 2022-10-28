require 'rails_helper'

RSpec.describe "Schedules", type: :system do
  let(:user) { create(:user, :default) }
  let(:schedule) { create(:schedule, :default) }

  describe 'ログイン前' do
    describe 'ページ遷移確認' do
      context 'スケジュール新規作成ページにアクセス' do
        it 'アクセスが失敗する' do
          visit new_schedule_path
          expect(page).to have_content I18n.t('defaults.please_login_first')
          expect(current_path).to eq login_path
        end
      end

      context 'スケジュール編集ページにアクセス' do
        it 'アクセスが失敗する' do
          visit edit_schedule_path(schedule)
          expect(page).to have_content I18n.t('defaults.please_login_first')
          expect(current_path).to eq login_path
        end
      end

      context 'スケジュール一覧ページにアクセス' do
        it 'アクセスが失敗する' do
          visit schedules_path
          expect(page).to have_content I18n.t('defaults.please_login_first')
          expect(current_path).to eq login_path
        end
      end
    end
  end

  describe 'ログイン後' do
    before { login_as(user) }

    describe 'スケジュール新規登録' do
      describe 'デフォルト作成' do
        before { visit new_schedule_path }

        context 'フォームの入力値が正常（to_be_sent）' do
          it 'スケジュールの新規作成に成功する' do
            fill_in 'schedule[title]', with: 'title'
            fill_in 'schedule[body]', with: 'body'
            fill_in 'schedule[start_time]', with: 1.day.since.beginning_of_day.in_time_zone
            fill_in 'schedule[end_time]', with: 1.day.since.beginning_of_day.in_time_zone + 1.hour
            select Schedule.statuses_i18n[:to_be_sent], from: 'schedule[status]'
            click_button I18n.t('helpers.submit.create')
            expect(page).to have_content I18n.t('schedules.create.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約される
            expect(user.schedules.last.job_id.present?).to eq true
          end
        end

        context 'フォームの入力値が正常（draft）' do
          it 'スケジュールの新規作成に成功する' do
            fill_in 'schedule[title]', with: 'title'
            fill_in 'schedule[body]', with: 'body'
            fill_in 'schedule[start_time]', with: 1.day.since.beginning_of_day.in_time_zone
            fill_in 'schedule[end_time]', with: 1.day.since.beginning_of_day.in_time_zone + 1.hour
            select Schedule.statuses_i18n[:draft], from: 'schedule[status]'
            click_button I18n.t('helpers.submit.create')
            expect(page).to have_content I18n.t('schedules.create.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約されない
            expect(user.schedules.last.job_id.present?).to eq false
          end
        end

        context '開始日時が現在より過去の日時になっている' do
          it 'スケジュールの新規作成に失敗する' do
            fill_in 'schedule[title]', with: 'title'
            fill_in 'schedule[body]', with: 'body'
            fill_in 'schedule[start_time]', with: 1.day.ago.beginning_of_day.in_time_zone
            fill_in 'schedule[end_time]', with: 1.day.since.beginning_of_day.in_time_zone + 1.hour
            select Schedule.statuses_i18n[:to_be_sent], from: 'schedule[status]'
            click_button I18n.t('helpers.submit.create')
            expect(page).to have_content I18n.t('schedules.create.fail')
            expect(current_path).to eq schedules_path
          end
        end

        context '開始日時が終了日時より過去の日時になっている' do
          it 'スケジュールの新規作成に失敗する' do
            fill_in 'schedule[title]', with: 'title'
            fill_in 'schedule[body]', with: 'body'
            fill_in 'schedule[start_time]', with: 1.day.since.beginning_of_day.in_time_zone
            fill_in 'schedule[end_time]', with: 1.day.since.beginning_of_day.in_time_zone - 1.hour
            select Schedule.statuses_i18n[:to_be_sent], from: 'schedule[status]'
            click_button I18n.t('helpers.submit.create')
            expect(page).to have_content I18n.t('schedules.create.fail')
            expect(current_path).to eq schedules_path
          end
        end

      end
    end

    describe 'スケジュール編集' do
      describe 'デフォルト作成' do
        let!(:to_be_sent_schedule) { create(:schedule, :default, user: user) }
        let!(:draft_schedule) { create(:schedule, :default, user: user, status: :draft) }

        context 'タイトルを変更（to_be_sent）' do
          it 'スケジュールの編集に成功する' do
            visit edit_schedule_path(to_be_sent_schedule)
            fill_in 'schedule[title]', with: 'updated title'
            click_button I18n.t('helpers.submit.update')
            expect(page).to have_content I18n.t('schedules.update.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約される
            expect(Schedule.find(to_be_sent_schedule.id).job_id.present?).to eq true
          end
        end

        context 'タイトルを変更（draft）' do
          it 'スケジュールの編集に成功する' do
            visit edit_schedule_path(draft_schedule)
            fill_in 'schedule[title]', with: 'updated title'
            click_button I18n.t('helpers.submit.update')
            expect(page).to have_content I18n.t('schedules.update.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約されない
            expect(Schedule.find(draft_schedule.id).job_id.present?).to eq false
          end
        end

        context '開始日時と終了日時を変更（to_be_sent）' do
          it 'スケジュールの編集に成功する' do
            visit edit_schedule_path(to_be_sent_schedule)
            fill_in 'schedule[start_time]', with: to_be_sent_schedule.start_time + 1.hour
            fill_in 'schedule[end_time]', with: to_be_sent_schedule.end_time + 1.hour
            click_button I18n.t('helpers.submit.update')
            expect(page).to have_content I18n.t('schedules.update.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約される
            expect(Schedule.find(to_be_sent_schedule.id).job_id.present?).to eq true
          end
        end

        context '開始日時と終了日時を変更（draft）' do
          it 'スケジュールの編集に成功する' do
            visit edit_schedule_path(draft_schedule)
            fill_in 'schedule[start_time]', with: to_be_sent_schedule.start_time + 1.hour
            fill_in 'schedule[end_time]', with: to_be_sent_schedule.end_time + 1.hour
            click_button I18n.t('helpers.submit.update')
            expect(page).to have_content I18n.t('schedules.update.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約されない
            expect(Schedule.find(draft_schedule.id).job_id.present?).to eq false
          end
        end

        context 'ステータスを変更（to_be_sentからdraft）' do
          it 'スケジュールの編集に成功する' do
            visit edit_schedule_path(to_be_sent_schedule)
            select Schedule.statuses_i18n[:draft], from: 'schedule[status]'
            click_button I18n.t('helpers.submit.update')
            expect(page).to have_content I18n.t('schedules.update.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約されない
            expect(Schedule.find(to_be_sent_schedule.id).job_id.present?).to eq false
          end
        end

        context 'ステータスを変更（draftからto_be_sent）' do
          it 'スケジュールの編集に成功する' do
            visit edit_schedule_path(draft_schedule)
            select Schedule.statuses_i18n[:to_be_sent], from: 'schedule[status]'
            click_button I18n.t('helpers.submit.update')
            expect(page).to have_content I18n.t('schedules.update.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約される
            expect(Schedule.find(draft_schedule.id).job_id.present?).to eq true
          end
        end
      end

      describe 'Googleカレンダー経由' do
        context 'スケジュール編集ページにアクセス' do
          it 'アクセスが失敗する' do
            google_schedule = create(:schedule, :google, user: user)
            visit edit_schedule_path(google_schedule)
            expect(page).to have_content I18n.t('defaults.invalid_access')
            expect(current_path).to eq dashboards_path
          end
        end
      end

      describe 'ページ遷移確認' do
        context '他のユーザーのスケジュール編集ページにアクセス' do
          it 'アクセスが失敗する' do
            another_user = create(:user, :default)
            another_schedule = create(:schedule, :default, user: another_user)
            visit edit_schedule_path(another_schedule)
            expect(page).to have_content I18n.t('defaults.invalid_access')
            expect(current_path).to eq dashboards_path
          end
        end
      end
    end

    describe 'スケジュール一覧' do
      let!(:to_be_sent_schedule) { create(:schedule, :default, user: user) }
      let!(:draft_schedule) { create(:schedule, :default, user: user, status: :draft) }
      let!(:google_schedule) { create(:schedule, :google, user: user) }
      before { visit schedules_path }

      describe 'デフォルト作成' do

        context 'スケジュール一覧ページにアクセス' do
          it '編集ボタンが表示される' do
            expect(page).to have_selector("#buttons-#{to_be_sent_schedule.id}", text: I18n.t('defaults.edit'))
            find('a', text: Schedule.statuses_i18n[:draft]).click
            expect(page).to have_selector("#buttons-#{draft_schedule.id}", text: I18n.t('defaults.edit'))
          end
        end

        context 'ステータスを変更（to_be_sentからdraft）' do
          it 'スケジュールの更新に成功する' do
            find("#buttons-#{to_be_sent_schedule.id}").click_button('送信予約取消')
            expect(page).to have_content I18n.t('schedules.update.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約されない
            expect(Schedule.find(to_be_sent_schedule.id).status).to eq 'draft'
            expect(Schedule.find(to_be_sent_schedule.id).job_id.present?).to eq false
          end
        end

        context 'ステータスを変更（draftからto_be_sent）' do
          it 'スケジュールの更新に成功する' do
            find('a', text: Schedule.statuses_i18n[:draft]).click
            find("#buttons-#{draft_schedule.id}").click_button('送信予約')
            expect(page).to have_content I18n.t('schedules.update.success')
            expect(current_path).to eq schedules_path

            # 通知メッセージ送信ジョブが予約される
            expect(Schedule.find(draft_schedule.id).status).to eq 'to_be_sent'
            expect(Schedule.find(draft_schedule.id).job_id.present?).to eq true
          end
        end
      end

      describe 'Googleカレンダー経由' do
        context 'スケジュール一覧ページにアクセス' do
          it '編集ボタンが表示されない' do
            expect(page).to have_no_selector("#buttons-#{google_schedule.id}", text: I18n.t('defaults.edit'))
          end
        end
      end
    end

    describe 'スケジュール削除' do
      let!(:default_schedule) { create(:schedule, :default, user: user) }
      let!(:google_schedule) { create(:schedule, :google, user: user) }
      before { visit schedules_path }

      describe 'デフォルト作成' do
        context 'スケジュール一覧ページで削除ボタンを押す' do
          it 'スケジュールの削除に成功する' do
            find("#buttons-#{default_schedule.id}").click_button('削除')
            expect(page).to have_content I18n.t('schedules.destroy.success')
            expect(current_path).to eq schedules_path
          end
        end
      end

      describe 'Googleカレンダー経由' do
        context 'スケジュール一覧ページにアクセス' do
          it 'スケジュールの削除ボタンが表示されない' do
            expect(page).to have_no_selector("#buttons-#{google_schedule.id}", text: '削除')
          end
        end
      end
    end

  end
end
