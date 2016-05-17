class Admin::Ticketing::CasesController < Admin::BaseController
  include ActionView::Helpers::TextHelper

  def index
    status = params[:status]
    status = ["open", "new"] if status == "open"
    
    @cases = Case.includes(:assignee).page(params[:page]).order(received_at: :desc)
    @cases = @cases.where(case_queue_id: params[:queue_id]) unless params[:queue_id].blank?
    @cases = @cases.where(assigned_to: params[:user_id]) unless params[:user_id].blank?
    @cases = @cases.where(status: status) unless status.blank?
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
    
    # update user_id if not set and information available
    
    if @case.user_id.nil? && !@case.email.blank?
      u = User.find_by(email: @case.email)
      
      if u
        @case.user_id = u.id
      elsif Rails.configuration.modules.include?(:store)
        o = Order.find_by(notify_email: @case.email)
        @case.user_id = o.user_id unless o.nil?
      end
      
      @case.save
    end
    
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
    redirect_to action: 'index', status: :open, queue_id: @case.casequeue_id, notice: 'Case has been deleted.'
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
  
  def update_status
    count = 0 
    
    Case.where(id: params[:case_id]).each do |c|
      next if c.status == params[:status]
      
      c.update_attribute(:status, params[:status])
      CaseUpdate.create(case_id: c.id, received_at: DateTime.now, user_id: session[:user_id], new_state: params[:status], response: "")
      count += 1
    end
    
    flash[:success] = "Status of #{pluralize(count, "case")} updated to '#{params[:status]}'."
    redirect_to :back
  end
  
  def delete_batch
    list = Case.destroy_all(id: params[:case_id])
    flash[:success] = "#{pluralize(list.length, "case")} deleted."
    redirect_to :back
  end
  
  
  private
  
    def case_params
      params.require(:case).permit!
    end
  
end
