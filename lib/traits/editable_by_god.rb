module Traits::EditableByGod
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def editable_by?(user)
      if user.respond_to?(:god?) and user.god?
        return true
      elsif respond_to?(:super)
        return super
      else
        return false
      end
    end
  end
end
