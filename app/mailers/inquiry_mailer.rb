class InquiryMailer < ApplicationMailer

  def inquiry_email(inquiry_body, reply_email_address)
    @inquiry_body = inquiry_body
    @reply_email_address = reply_email_address
    mail to: ENV['GMAIL_ADDRESS'], subject: "お問い合わせメール（トリコミ）"
  end
end
