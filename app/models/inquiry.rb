class Inquiry
  # DBと結びつかない（＝ActiveRecordを継承しない）クラスでActive Modelの機能を使う
  # https://railsguides.jp/active_model_basics.html
  include ActiveModel::Model

  attr_accessor :email, :body

  validates :email, presence: true
  validates :body, presence: true, length: { maximum: 65535 }
end
