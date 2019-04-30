class Admin::Ticketing::CasesController < Admin::BaseController
  include ActionView::Helpers::TextHelper

  def index
    authorize Case.new
    
    status = params[:status]
    status = ["open", "new"] if status == "open"
    q = params[:q]
    
    @cases = Case.includes(:assignee).order(received_at: :desc)
    @cases = @cases.where(case_queue_id: params[:queue_id]) unless params[:queue_id].blank?
    @cases = @cases.where(assigned_to: params[:user_id]) unless params[:user_id].blank?
    @cases = @cases.where(status: status) unless status.blank?
    @cases = @cases.where("name LIKE '%#{q}%' OR subject LIKE '%#{q}%' OR description LIKE '%#{q}%'") unless q.blank?

    respond_to do |format|
      format.html { @cases = @cases.paginate(page: params[:page], per_page: @per_page) }
      format.csv { send_data Case.to_csv(@cases, skip_cols: ['raw_data']) }
    end
  end

  def new
    @case = authorize Case.new(received_via: "Email", priority: :normal, status: :new, case_queue_id: params[:queue_id], user_id: params[:user_id])
    render 'edit'
  end

  def create
    @case = authorize Case.new(case_params)
    
    if @case.save
      redirect_to action: 'index', notice: 'Case was successfully created.'
    else
      render 'edit'
    end
  end

  def show
    @case = authorize Case.find(params[:id])
    
    # update user_id if not set and email information available    
    if @case.user_id.nil? && !@case.email.blank?
      u = User.find_by(email: @case.email)
      
      if u
        @case.update(user_id: u.id)
      elsif Rails.configuration.modules.include?(:store)
        o = Order.find_by(notify_email: @case.email)
        @case.update(user_id: o.user_id) unless o.nil?
      end
    end
    
    # update user_id if not set and phone number information available    
    if @case.user_id.nil? && @case.subject.include?("Voicemail")
      
      number = @case.subject.scan(/\d+/).first
      u = User.find_by(phone: number)
      
      @case.update(phone: number) if @case.phone.blank? && !number.blank?
        
      if u
        @case.update(user_id: u.id, name: u.name, email: u.email)
      elsif Rails.configuration.modules.include?(:store)
        o = Order.find_by(contact_phone: number)
        @case.update(user_id: o.user_id, name: o.billing_name, email: o.notify_email) unless o.nil?
      end
    end
    
  end

  def edit
    @case = authorize Case.find(params[:id])
  end

  def update
    @case = authorize Case.find(params[:id])
    
    if @case.update(case_params)
      redirect_to action: 'index', notice: 'Case was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @case = authorize Case.find(params[:id])
    @case.destroy
    redirect_to action: 'index', status: :open, queue_id: @case.casequeue_id, notice: 'Case has been deleted.'
  end
  
  def raw_data
    @case = Case.find(params[:id])
    authorize @case, :show?
    
    send_data @case.raw_data, type: "text/plain", disposition: "inline"
  end
  
  def attachment
    @case = Case.find(params[:id])
    authorize @case, :show?
    
    attachment = Mail.new(@case.raw_data).attachments.find { |x| x.filename == params[:filename] }
    unless attachment.nil?
      send_data attachment.body.decoded, type: attachment.content_type
    else
      render :status => 404
    end
  end
  
  def update_status
    authorize Case, :update?
    count = 0 
    
    Case.where(id: params[:case_id]).each do |c|
      next if c.status == params[:status]
      
      c.update_attribute(:status, params[:status])
      CaseUpdate.create(case_id: c.id, received_at: DateTime.now, user_id: session[:user_id], new_state: params[:status], response: "")
      count += 1
    end
    
    flash[:success] = "Status of #{pluralize(count, "case")} updated to '#{params[:status]}'."
    redirect_back(fallback_location: admin_ticketing_cases_path)
  end
  
  def delete_batch
    authorize Case, :destroy?
    
    list = Case.where(id: params[:case_id]).destroy_all
    flash[:success] = "#{pluralize(list.length, "case")} deleted."
    redirect_back(fallback_location: admin_ticketing_cases_path)
  end
  
  
  private
  
    def case_params
      params.require(:case).permit!
    end
  
end
