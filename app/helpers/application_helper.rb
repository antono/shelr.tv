module ApplicationHelper
  def player_for(record, options = {})
    render partial: 'shared/player', locals: { record: record, embed: options[:embed] }
  end

  def controller_and_action_class_names
    [controller_name, '-controller', ' ', action_name, '-action'].join
  end

  def active_if(regex)
    'active' if request.env['PATH_INFO'] =~ regex
  end
end
