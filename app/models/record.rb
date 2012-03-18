class Record

  LICENSES = {
    "by-sa" => "http://creativecommons.org/licenses/by-sa/3.0/"
  }

  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongo

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

  referenced_in :user

  attr_accessible :title, :description, :typescript,
                  :timing, :tags, :columns, :rows

  before_create :set_license
  after_create  :increment_counters!
  after_destroy :decrement_counters!

  searchable do
    text :title, :boost => 5.0
    text :description_html, :boost => 3.0
    text :tags, :boost => 4.0 do
      read_attribute(:tags)
    end
    text :typescript, :boost => 0.3
    time :updated_at
    time :created_at
  end

  class << self
    def find_in_batches(options = {})
      options[:per] ||= 10
      last_page = (self.count / options[:per]) + 1
      1.upto(last_page).each do |batch_number|
        yield page(batch_number).per(options[:per])
      end
    end

    def reindex!
      find_in_batches(:per => 10) do |batch|
        batch.each do |record|
          index record
        end
      end
    end
  end

  def self.per_page
    5
  end

  def owner
    self.user
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
