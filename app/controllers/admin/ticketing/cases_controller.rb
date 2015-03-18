class Admin::Ticketing::CasesController < Admin::BaseController

  def index
    @cases = Case.page(params[:page]).order(received_at: :desc)
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
  
  def raw_data
    @case = Case.find(params[:id])
    send_data @case.raw_data, type: "text/plain", disposition: "inline"
  end
  
  def attachment
    @case = Case.find(params[:id])
    attachment = Mail.new(@case.raw_data).attachments.find { |x| x.filename == params[:filename] }
    unless attachment.nil?
      send_data attachment.body.decoded, type: attachment.content_type
    else
      render :status => 404
    end
  end
  
  private
  
    def case_params
      params.require(:case).permit!
    end
  
end
