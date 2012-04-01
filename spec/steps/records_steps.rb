step "I should see :some records" do |some|
  case some
  when 'some'
    page.find('.records .record').should_not raise_error Capybara::ElementNotFound
  when '0'
    page.find('.records .record').should raise_error Capybara::ElementNotFound
  else
    page.find('.records .record').should_not raise_error Capybara::ElementNotFound
    page.find('.records .record').count.should == Integer(some)
  end
end

step "there is/are :num record(s) in db" do |num|
  num = Integer(num)
  case num
  when 0
    Record.destroy_all
  else
    (num - Record.count).times do
      FactoryGirl.create(:record)
    end
  end
end
