class Account::CasesController < Account::BaseController

  def index
    @cases = Case.where(user_id: session[:user_id]).order('created_at DESC')
  end

  def show
    @case = Case.find_by(user_id: session[:user_id], id: param[:id]).includes(:updates, :details)
  end

end
