module LoginMacros
  def login_as(user)
    visit login_path
    if user.default? #デフォルトログイン
      fill_in 'email', with: user.email
      fill_in 'password', with: 'password'
      click_button I18n.t('defaults.login')
    else #Googleログイン
      #あとで書く
    end
  end
end