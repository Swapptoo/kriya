module ApplicationHelper

  def no_header?
    controller_name == 'sessions'
  end

  def toggle_class_name(class_name, condition = true)
    class_name if condition
  end
end
