module CaseHelper
  
  def case_status_indicator(status)

		status = status.status if status.class.name == "Case"

    if status == 'new'
      css_class = 'label-info'
    elsif status == 'open'
      css_class = 'label-success'
    elsif status == 'closed'
      css_class = 'label-danger'
    else
      css_class = 'label-default'
    end
  
    "<span class='label #{css_class}'>#{status}</span>".html_safe
  end
  
  def case_priority_indicator(priority)

		priority = priority.priority if priority.class.name == "Case"

    if priority == 'high'
      css_class = 'label-warning'
    elsif priority == 'normal'
      css_class = 'label-default'
    elsif priority == 'urgent'
      css_class = 'label-danger'
    else
      css_class = 'label-default'
    end
  
    "<span class='label #{css_class}'>#{priority}</span>".html_safe
  end
  
end