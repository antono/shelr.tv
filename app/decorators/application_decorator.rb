class ApplicationDecorator < Draper::Base
  def as_json(options = {})
    model.as_json(options)
  end
end
