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
      Rails.cache.delete :case_queue_list
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
      Rails.cache.delete :case_queue_list
      redirect_to action: 'index', notice: 'Case Queue was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @case_queue = CaseQueue.find(params[:id])
    @case_queue.destroy
    
    Rails.cache.delete :case_queue_list
    redirect_to action: 'index', notice: 'Case Queue has been deleted.'
  end
  
  
  private
  
    def case_queue_params
      params.require(:case_queue).permit!
    end
  
end
