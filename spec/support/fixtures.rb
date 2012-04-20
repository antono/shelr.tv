def load_record_fixture(filename)
  File.read(Rails.root.join('spec', 'fixtures', filename))
end

def extend_record_fixture(filename, options)
  JSON.parse(load_record_fixture(filename)).merge(options).to_json
end
