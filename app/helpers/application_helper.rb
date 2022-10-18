module ApplicationHelper
  def page_title(page_title = '')
    base_title = 'トリコミ - リモートワーカー向けスケジュール共有サービス'
    page_title.empty? ? base_title : page_title + ' | ' + base_title
  end
end
