class Record

  include Mongoid::Document

  field :title,        type: String
  field :description,  type: String
  field :typescript,   type: String
  field :timing,       type: String
  field :tags,         type: Array
  field :created_at,   type: DateTime

  attr_accessible :title, :description, :typescript, :timing, :tags

  referenced_in :user

  after_create :timestamp!, :increment_counters!
  after_destroy :decrement_counters!

  def self.per_page
    5
  end

  def title
    read_attribute(:title).blank? ? 'untitled' : read_attribute(:title)
  end

  def description_html
    Maruku.new(description).to_html.html_safe
  end

  def tags=(tags)
    write_attribute(:tags, tags.split(",").map(&:strip))
  end

  def tags
    read_attribute(:tags).try(:join, ", ")
  end

  def editable_by?(usr)
    return false if usr.nil?
    return true  if usr.nickname == 'antono'
    self.user.id.to_s == usr.id.to_s
  end

  def timestamp!
    write_attribute(:created_at, Time.now)
  end

  def increment_counters!
    # FIXME self.user.inc(:records_count, 1)
  end

  def decrement_counters!
    # FIXME self.user.inc(:records_count, -1)
  end
end
