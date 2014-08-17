class Admin::Ticketing::CaseQueuesController < Admin::BaseController
  
  def index
    @case_queues = CaseQueue.page(params[:page]).order('name')
  end

  def new
    @case_queue = CaseQueue.new name: 'New queue'
    render 'edit'
  end

  def create
    @case_queue = CaseQueue.new(case_queue_params)
    
    if @case_queue.save
      redirect_to action: 'index', notice: 'Case Queue was successfully created.'
    else
      render 'edit'
    end
  end

  def show
    @case_queue = CaseQueue.find(params[:id])
  end

  def edit
    @case_queue = CaseQueue.find(params[:id])
  end

  def update
    @case_queue = CaseQueue.find(params[:id])
    
    if @case_queue.update(case_queue_params)
      redirect_to action: 'index', notice: 'Case Queue was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @case_queue = CaseQueue.find(params[:id])
    @case_queue.destroy
    redirect_to action: 'index', notice: 'Case Queue has been deleted.'
  end
  
  
  private
  
    def case_queue_params
      params.require(:case_queue).permit(:name, :notify_email, :initial_assignment, :reply_name, :reply_email, :reply_signature, 
      :web_instruction, :web_confirmation, :pop3_enabled, :pop3_host, :pop3_login, :pop3_password, :pop3_use_ssl, :pop3_error)
    end
  
end
