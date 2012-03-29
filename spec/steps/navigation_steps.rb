step "I signed in" do |page|
  visit "/auth/developer"
  fill_in 'Name', with: 'antono'
  fill_in 'Email', with: 'self@antono.info'
  click_button 'Sign In'
  page.should have_content 'Profile'
  click_button 'Save'
end

step "I'm on the :page page" do |page|
  visit page
end
