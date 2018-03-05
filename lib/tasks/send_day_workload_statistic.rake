desc "Send day workload statistic"
task :send_day_workload_statistic => :environment do

  include StatisticHelper
  include SlackNotificatorHelper

  day_statistic_enable  = Setting.plugin_workload_statistic_notificator['day_statistic_enable']

  if day_statistic_enable
    time_now           = Time.now.strftime("%H:%M")
    day_statistic_time = Setting.plugin_workload_statistic_notificator['day_statistic_time']

    p time_now

    if time_now == day_statistic_time

      url     = Setting.plugin_workload_statistic_notificator['slack_url']
      channel = Setting.plugin_workload_statistic_notificator['day_statistic_channel']
      icon    = Setting.plugin_workload_statistic_notificator['icon']

      color_top    = '#2FA44F'
      color_bottom = '#F35A00'
      color_idle   = '#E2E3E5'

      statistic = StatisticHelper::get_day_statistic

      message = "*Day Statistic #{ DateTime.now.strftime("%d-%b-%Y")}*"

      if statistic[:time_top].empty? && statistic[:time_bottom].empty? && statistic[:time_idle].empty?
        attachment = [
            {
                :text => "it seems like no users are selected for the report or non of them are assigned to internal projects",
            }
        ]

      else
        attachment = []
        statistic[:time_top].each do |item|
          attachment.push({
                              :text      => "#{item[0]} `#{item[1]} %`",
                              :mrkdwn_in => ["text"],
                              :color     => color_top
                          })
        end

        statistic[:time_bottom].each do |item|
          attachment.push({
                              :text      => "#{item[0]} `#{item[1]} %`",
                              :mrkdwn_in => ["text"],
                              :color     => color_bottom
                          })
        end

        statistic[:time_idle].each do |item|
          attachment.push({
                              :text      => "#{item[0]}",
                              :mrkdwn_in => ["text"],
                              :color     => color_idle
                          })
        end
      end

      SlackNotificatorHelper::send_notification url, channel, icon, message, attachment

    end
  else
    p 'Day statistic is disabled in plugin configuration'
  end

end
