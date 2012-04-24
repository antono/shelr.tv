class Comment

  COMMENTABLES = ['record']

  include Mongoid::Document
  include Mongoid::Timestamps

  field :body,       type: String
  field :created_at, type: DateTime, index: true
  field :updated_at, type: DateTime

  belongs_to :commentable, polymorphic: true
  belongs_to :user, index: true

  validates :user, presence: true

  attr_accessible :body

  def self.for(commentable, commentable_id)
    if COMMENTABLES.include?(commentable)
      commentable.classify.constantize.find(commentable_id).comments
    end
  end

  alias owner user

  def editable_by?(usr)
    return false if not usr.is_a?(User)
    return true  if usr.god?
    self.user.id == usr.id
  end

end
