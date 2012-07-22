step "I should see :number comment(s) on dashboard" do |num|
  page.should have_css('.comments .comment', count: num)
end
