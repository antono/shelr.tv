class Comment

  include Mongoid::Document
  include Mongoid::Timestamps

  field :body,       type: String
  field :created_at, type: DateTime
  field :updated_at, type: DateTime

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  def owner
    user
  end

  def editable_by?(usr)
    return false if not usr.is_a?(User)
    return true  if usr.god?
    self.user.id == usr.id
  end

end
