class CasesController < ApplicationController
  
  def new
    @case = Case.new(subject: params[:subject])
    @case.assign_attributes(name: current_user.name, email: current_user.email) if logged_in?
  end
  
  def create
    @case = Case.new(case_params)
    q = CaseQueue.find(@case.case_queue_id)
    
    @case.assign_attributes(
      received_at: DateTime.now,
      received_via: :web,
      priority: :normal,
      status: :new,
      user_id: session[:user_id],
      assigned_to: q.initial_assignment    
    )
    
    if @case.web_submission_valid? && @case.save
      CaseMailer.assigned(@case).deliver_later unless q.initial_assignment.nil?
      redirect_to action: 'show', id: @case.id
    else
      render 'new'
    end
  end
  
  def show
    @case = Case.find(params[:id])
  end
  
  
  private
  
    def case_params
      params.require(:case).permit(:case_queue_id, :name, :email, :phone, :subject, :description)
    end
  
end
