class Admin::Ticketing::CaseQueuesController < Admin::BaseController

  def index
    authorize CaseQueue.new
    @case_queues = CaseQueue.order(:name)

    respond_to do |format|
      format.html { @case_queues = @case_queues.paginate(page: params[:page], per_page: @per_page) }
      format.csv { send_data CaseQueue.to_csv(@case_queues) }
    end
  end

  def new
    @case_queue = authorize CaseQueue.new(name: 'New queue')
    render 'edit'
  end

  def create
    @case_queue = authorize CaseQueue.new(case_queue_params)

    if @case_queue.save
      Rails.cache.delete :case_queue_list
      redirect_to action: 'index', notice: 'Case Queue was successfully created.'
    else
      render 'edit'
    end
  end

  def show
    @case_queue = authorize CaseQueue.find(params[:id])
  end

  def edit
    @case_queue = authorize CaseQueue.find(params[:id])
  end

  def update
    @case_queue = authorize CaseQueue.find(params[:id])

    if @case_queue.update(case_queue_params)
      Rails.cache.delete :case_queue_list
      redirect_to action: 'index', notice: 'Case Queue was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @case_queue = authorize CaseQueue.find(params[:id])
    @case_queue.destroy

    Rails.cache.delete :case_queue_list
    redirect_to action: 'index', notice: 'Case Queue has been deleted.'
  end


  private

  def case_queue_params
    params.require(:case_queue).permit!
  end

end
