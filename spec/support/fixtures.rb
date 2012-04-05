def load_record(filename)
  JSON.parse(File.read(Rails.root.join('spec', 'fixtures', filename)))
end
