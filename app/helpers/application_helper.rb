module ApplicationHelper

  def no_header?
    controller_name == 'sessions'
  end

  def toggle_class_name(class_name, condition = true)
    class_name if condition
  end

  def freelancer_after_sign_up_greeting
    description = content_tag :p, 'Welcome to the Kriya network. We’re excited to have a partner with your expertise and talent. Here at Kriya, we believe in distribution of work and our mission is to provide you with a steady flow of valuable work.'

    term_title = content_tag :p do
      content_tag :strong, 'Our Terms'
    end

    terms = content_tag :div, class: 'ui ordered list' do
      concat content_tag(:div, 'When we assign you to a task, you will get notified in email or Slack.',class: 'item')
      concat content_tag(:div, 'After accepting the task, remember to introduce yourself.',class: 'item')
      concat content_tag(:div, 'Explain your rates, propose a few times that work for an initial call,',class: 'item')
      concat content_tag(:div, 'The budget is a starting point and is always negotiable',class: 'item')
      concat content_tag(:div, 'If you use Slack, feel free to integrate with it. This will be useful for keeping the lines of communication open.',class: 'item')
    end

    content_tag :div, class: 'freelancer after-sign-up-greeting' do
      concat description
      concat term_title
      concat terms
    end.html_safe
  end
end
