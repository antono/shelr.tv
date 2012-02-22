class Record

  LICENSES = {
    "by-sa" => "http://creativecommons.org/licenses/by-sa/3.0/"
  }

  include Mongoid::Document
  include Mongoid::Timestamps


  field :title,        type: String
  field :description,  type: String
  field :columns,      type: Integer
  field :rows,         type: Integer
  field :typescript,   type: String
  field :timing,       type: String
  field :tags,         type: Array
  field :license,      type: String
  field :created_at,   type: DateTime
  field :updated_at,   type: DateTime

  attr_accessible :title, :description, :typescript, :timing, :tags, :columns, :rows

  referenced_in :user

  before_create :set_license
  after_create :increment_counters!
  after_destroy :decrement_counters!

  def self.per_page
    5
  end

  def title
    read_attribute(:title).blank? ? 'untitled' : read_attribute(:title)
  end

  def description_html
    Maruku.new(description).to_html
  end

  def tags=(tags)
    write_attribute(:tags, tags.split(",").map(&:strip))
  end

  def size
    [ self.columns || 80, 'x', self.rows || 24 ].join
  end

  def tags
    read_attribute(:tags).try(:join, ", ")
  end

  def editable_by?(usr)
    return false if usr.nil?
    return true  if usr.nickname == 'antono'
    self.user.id.to_s == usr.id.to_s
  end

  def set_license
    self.license = 'by-sa'
  end

  def increment_counters!
    # FIXME self.user.inc(:records_count, 1)
  end

  def decrement_counters!
    # FIXME self.user.inc(:records_count, -1)
  end
end
