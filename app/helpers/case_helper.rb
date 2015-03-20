module CaseHelper
  
  def case_status_indicator(c)

    if c.status == 'new'
      css_class = 'label-info'
    elsif c.status == 'open'
      css_class = 'label-success'
    elsif c.status == 'closed'
      css_class = 'label-danger'
    else
      css_class = 'label-default'
    end
  
    "<span class='label #{css_class}'>#{c.status}</span>".html_safe
  end
  
  def case_priority_indicator(c)

    if c.priority == 'high'
      css_class = 'label-warning'
    elsif c.priority == 'normal'
      css_class = 'label-default'
    elsif c.priority == 'urgent'
      css_class = 'label-danger'
    else
      css_class = 'label-default'
    end
  
    "<span class='label #{css_class}'>#{c.priority}</span>".html_safe
  end
  
end