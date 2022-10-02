class LineLogin::LoginUrlValidateService
  def initialize(params)
    @user = User.find_by(id: params[:app_user_id])
    @link_token = LinkToken.find_by(user_id: params[:app_user_id], token_digest: Digest::MD5.hexdigest(params[:link_token]))
    @self = params[:self]
  end

  def call
    # @user、@link_tokenが存在し、@selfが正しいフォーマットの場合にLINEログイン処理へ移る
    # @selfは、アプリユーザーが自分のLINEアカウントを登録しようとしているときにtrue
    # アプリユーザーが自分でないLINEユーザーに登録してもらおうとしているときにfalse
    @user && @link_token && ( @self == 'true' || @self == 'false' )
  end
end