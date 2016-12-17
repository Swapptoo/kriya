module PostsHelper
  def truncate_body_link text
    truncate(text, length: 50)
  end
end
