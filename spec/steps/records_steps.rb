steps_for :records do

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

  step "I should see player for :record_title" do |title|
    within '#player' do
      page.should have_content title
      page.should have_css '#term'
      page.should have_css 'nav.controls'
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

  step "there are following records" do |table|
    @_records = {}
    table.hashes.each do |hash|
      record_json = load_record('ls.json')
      record_json.delete('created_at')
      record = Factory.build(:record, record_json)
      record.title = hash['title']
      record.user = Factory(:user, nickname: hash['nickname'])
      record.save
      @_records[hash['title']] = record
    end
  end
end
