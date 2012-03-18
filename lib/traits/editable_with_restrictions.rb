module Traits::EditableWithRestrictions
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def editable_by?(user)
      if user.blank?
        return false
      elsif respond_to?(:super)
        return super
      else
        return false
      end
    end
  end
end
