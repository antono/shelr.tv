class Record

  include Mongoid::Document

  field :title,        type: String
  field :description,  type: String
  field :typescript,   type: String
  field :timing,       type: String
  field :tags,         type: Array

  attr_accessible :title, :description, :typescript, :timing, :tags

  referenced_in :user

  def self.per_page
    5
  end

  def title
    read_attribute(:title).blank? ? 'untitled' : read_attribute(:title)
  end

  def tags=(tags)
    write_attribute(:tags, tags.split(",").map(&:strip))
  end

  def tags
    read_attribute(:tags).try(:join, ", ")
  end

  def editable_by?(usr)
    return false if usr.nil?
    self.user.id.to_s == usr.id.to_s
  end
end
