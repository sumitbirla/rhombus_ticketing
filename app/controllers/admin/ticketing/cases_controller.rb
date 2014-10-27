class Admin::Ticketing::CasesController < Admin::BaseController

  def index
    @cases = Case.page(params[:page]).order('name')
  end

  def new
    @case = Case.new received_via: "Email", priority: "Normal", status: "New", case_queue_id: params[:queue_id]
    render 'edit'
  end

  def create
    @case = Case.new(case_params)
    
    if @case.save
      redirect_to action: 'index', notice: 'Case was successfully created.'
    else
      render 'edit'
    end
  end

  def show
    @case = Case.find(params[:id])
  end

  def edit
    @case = Case.find(params[:id])
  end

  def update
    @case = Case.find(params[:id])
    
    if @case.update(case_params)
      redirect_to action: 'index', notice: 'Case was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @case = Case.find(params[:id])
    @case.destroy
    redirect_to action: 'index', notice: 'Case has been deleted.'
  end
  
  
  private
  
    def case_params
      params.require(:case).permit(:case_queue_id, :user_id, :name, :subject, :assigned_to, :priority, :status,
                                   :phone, :email, :description, :received_via) #, :form_data)
    end
  
end
