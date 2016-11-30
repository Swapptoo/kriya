FactoryGirl.create(
  :user,
  :email => 'manager@kriya.ai',
  :password => 'qwertyuiop',
  :password_confirmation => 'qwertyuiop',
  :username => 'goompmanager',
  :first_name => 'Manager',
  :last_name => 'Goomp',
  :slug => 'goomp-manager',
  :headline => 'Manager',
  :picture => 'https://www.filestackapi.com/api/file/6hx3CLg3SQGoARFjNBGq') unless User.where(:email => 'manager@kriya.ai').first

u = User.where(:email => 'manager@kriya.ai').first
u.update!({:picture => 'https://www.filestackapi.com/api/file/6hx3CLg3SQGoARFjNBGq'}) unless u.nil?
