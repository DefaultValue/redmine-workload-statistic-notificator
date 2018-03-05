require 'redmine'

Redmine::Plugin.register :workload_statistic_notificator do
  name 'Workload Statistic notificator plugin'
  author 'Default Value'
  description 'Plugin provides functionality for sending Slack workload statistic notifications'
  version '1.0'
  author_url 'http://default-value.com/'
  url 'https://github.com/DefaultValue/redmine-workload-statistic-notificator'

  settings \
      :default => {
      'slack_url'                 => 'http://slack.com/callback/',
      'slack_icon'                => 'https://raw.github.com/sciyoshi/redmine-slack/gh-pages/icon.png',
      'daily_working_hours'       => '8.0',
      'day_statistic_time'        => '20:00',
      'day_statistic_channel'     => 'general',
      'day_statistic_enable'      => true,
      'is_internal_project_attr'  => 'Internal project',
      },
      :partial => 'settings/workload_notificator_settings'

end

ActionDispatch::Reloader.to_prepare do
  SettingsHelper.send :include, NotificatorSettingsHelper
end
