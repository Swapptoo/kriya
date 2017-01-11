module ApplicationHelper

  def no_header?
    true
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
      concat content_tag(:div, 'Please DON\'T share your contact information. It\'s against our terms and conditions.',class: 'item')
      concat content_tag(:div, 'When we assign you to a task, you will get notified in email or Slack. We are currently giving preference to those who are available on demand. Meaning, when we assign a job to you, we expect there to be an immediate response. If you do not respond within 20 min, we will assign the job to someone else. Remember, the more successful we are, the more $$ for you! ',class: 'item')
      concat content_tag(:div, 'After accepting the task, remember to introduce yourself.',class: 'item')
      concat content_tag(:div, 'Explain your rates, propose a few times that work for an initial call,',class: 'item')

    end

    content_tag :div, class: 'freelancer after-sign-up-greeting' do
      concat description
      concat term_title
      concat terms
    end.html_safe
  end
end
