module ApplicationHelper
  def page_title(page_title = '')
    base_title = 'トリコミ 今、取り込み中をLINEでお知らせ'
    page_title.empty? ? base_title : page_title + ' | ' + base_title
  end
end
