class CasesController < ApplicationController
  
  def new
    @case = Case.new
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
    
    if @case.save
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
