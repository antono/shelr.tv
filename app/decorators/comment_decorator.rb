class CommentDecorator < ApplicationDecorator
  decorates :comment
  decorates_association :user

  def body
    h.link_to(h.sanitize(model.body), record_path)
  end

  def updated_at
    h.link_to(h.l(model.updated_at, format: :short), record_path)
  end

  def nickname
    h.link_to(model.user.nickname, model.user)
  end

  def avatar
    h.image_tag(self.user.avatar_url(50))
  end

  private

  def record_path
    h.record_path(model.commentable, anchor: h.dom_id(model))
  end
end
