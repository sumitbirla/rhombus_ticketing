class Admin::Ticketing::CaseUpdatesController < ApplicationController
  
  def create
    @case_update = CaseUpdate.new(case_update_params)
    @case_update.received_at = DateTime.now
    
    if @case_update.save
      @case_update.case.update_attribute(:status, @case_update.new_state) unless @case_update.new_state.blank?
      @case_update.case.update_attribute(:priority, @case_update.new_priority) unless @case_update.new_priority.blank?
      
      unless @case_update.new_assignee.nil?
        @case_update.case.update_attribute(:assigned_to, @case_update.new_assignee)
        CaseMailer.assigned(@case_update.case).deliver
      end
      
      unless @case_update.response.blank?
        begin
          CaseMailer.response(@case_update).deliver
        rescue => e
          flash[:error] = "Error sending email: " + e.message
        end
      end
      
      flash[:info] = "Case has been updated"
    else
      flash[:error] = @case_update.errors.full_messages.join("<br>").html_safe
    end
    
    redirect_to :back
  end
  
  def raw_data
    @case_update = CaseUpdate.find(params[:id])
    send_data @case_update.raw_data, type: "text/plain", disposition: "inline"
  end
  
  def attachment
    @case_update = CaseUpdate.find(params[:id])
    attachment = Mail.new(@case_update.raw_data).attachments.find { |x| x.filename == params[:filename] }
    unless attachment.nil?
      send_data attachment.body.decoded, type: attachment.content_type
    else
      render :status => 404
    end
  end
  
  
  private
  
    def case_update_params
      params.require(:case_update).permit!
    end
    
end
