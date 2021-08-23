module CaseHelper
  def case_status_indicator(status)
    status = status.status if status.class.name == "Case"

    if status == 'new'
      css_class = 'label-info'
    elsif status == 'open'
      css_class = 'label-success'
    else
      css_class = 'label-default'
    end

    "<span class='label #{css_class}'>#{status}</span>".html_safe
  end

  def case_priority_indicator(priority)
    priority = priority.priority if priority.class.name == "Case"

    list_item = ListItem.joins(:list)
                        .where(value: priority)
                        .where("cms_lists.name = ? AND cms_lists.affiliate_id = ?", :ticket_priorities, current_user.affiliate_id)
                        .first

    if list_item.nil?
      if priority == 'high'
        css_class = 'label-warning'
      elsif priority == 'normal'
        css_class = 'label-default'
      elsif priority == 'urgent'
        css_class = 'label-danger'
      else
        css_class = 'label-default'
      end

      str = "<span class='label #{css_class}'>#{priority}</span>"
    else
      str = "<span class='label' style='background-color: #{list_item.background_color}; color: #{list_item.foreground_color}'>#{priority}</span>"
    end

    str.html_safe
  end
end