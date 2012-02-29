class Record

  LICENSES = {
    "by-sa" => "http://creativecommons.org/licenses/by-sa/3.0/"
  }

  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid

  field :title,        type: String
  field :description,  type: String
  field :columns,      type: Integer
  field :rows,         type: Integer
  field :typescript,   type: String
  field :timing,       type: String
  field :tags,         type: Array
  field :license,      type: String
  field :hits,         type: Integer
  field :created_at,   type: DateTime
  field :updated_at,   type: DateTime

  searchable do
    text :title, :boost => 2.0, :stored => true
    text :description, :boost => 1.0, :stored => true
    text :tags, :boost => 5.0, :stored => true, :more_like_this => true
    # text :comments do
    #   comments.map { |comment| comment.body }
    # end
  end

  attr_accessible :title, :description, :typescript,
                  :timing, :tags, :columns, :rows

  referenced_in :user

  before_create :set_license
  after_create :increment_counters!
  after_destroy :decrement_counters!

  def self.per_page
    5
  end

  def title
    if read_attribute(:title).blank?
      'untitled'
    else
      read_attribute(:title)
    end
  end

  def description_html
    RDiscount.new(description).to_html
  end

  def tags=(tags)
    write_attribute(:tags, tags.split(",").map(&:strip))
  end

  def size
    [self.columns, 'x', self.rows].join
  end

  def columns
    read_attribute(:columns) or 80
  end
  
  def rows
    read_attribute(:rows) or 24
  end

  def tags
    read_attribute(:tags).try(:join, ", ")
  end

  def editable_by?(usr)
    return false if not usr.is_a?(User)
    return true  if usr.god?
    self.user.id == usr.id
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
