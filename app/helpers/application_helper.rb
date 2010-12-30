module ApplicationHelper
  def player_for(record)
    render partial: 'shared/player', locals: { record: record }
  end
end
