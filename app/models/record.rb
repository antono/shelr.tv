class Record < ActiveRecord::Base
  belongs_to :user

  def self.from_bundle(bundle)
    meta = JSON.parse(bundle['meta'])
    new(title: meta['title'], meta: bundle[:meta], typescript: bundle[:data], timing: bundle[:timing])
  end

  def editable_by?(user)
    id == user.id
  end

end
