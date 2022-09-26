class InquiryMailer < ApplicationMailer
  def inquiry_email(email, body)
    @email = email #返信先メールアドレス
    @body = body #お問い合わせ内容
    mail to: [email, ENV['GMAIL_ADDRESS']], subject: "お問い合わせ受付のお知らせ（トリコミ）"
  end
end
