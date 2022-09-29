class LineLogin::LoginUrlValidateSerivce
  def initialize(params)
    @user = User.find_by(id: params[:app_user_id].to_i)
    @link_token = params[:link_token]
    @self = params[:self]
  end

  def call
    # @userが存在し、@link_tokenが正しく、@selfが正しいフォーマットの場合にLINEログイン処理へ移る
    # @selfは、アプリユーザーが自分のLINEアカウントを登録しようとしているときにtrue
    # アプリユーザーが自分でないLINEユーザーに登録してもらおうとしているときにfalse
    @user && LinkToken.valid?(@user.id, @link_token) && ( @self == 'true' || @self == 'false' )
  end
end