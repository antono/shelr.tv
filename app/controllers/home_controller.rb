class HomeController < ApplicationController
  respond_to :html, :xml, :atom

  def landing
    if logged_in? && current_user.comments_for_records.any?
      redirect_to dashboard_path
    else
      @records = RecordDecorator.decorate(Record.visible_by(current_user).desc(:created_at).page(1))
    end
  end

  def opensearch
    response.headers["Content-Type"] = 'application/opensearchdescription+xml'
    render :layout => false
  end

  def dashboard
    if request.format == 'atom'
      if params[:key].present?
        @user = User.where(atom_key: params[:key]).first

        if @user.present?
          @comments = CommentDecorator.decorate(@user.comments_for_records.reverse)
        else
          render text: ''
        end
      else
        render text: ''
      end
    else
      if logged_in?
        page      = params[:page] || 1
        comments  = current_user.comments_for_records
        comments  = Kaminari.paginate_array(comments).page(page).per(20)
        @comments = CommentDecorator.decorate(comments)
      else
        redirect_to records_path
      end
    end
  end
end
