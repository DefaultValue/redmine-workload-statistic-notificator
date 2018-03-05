module StatisticHelper

  include NotificatorSettingsHelper

  def get_day_statistic
    user_notification_settings = get_user_notification_settings
    internal_project_attr      = Setting.plugin_workload_statistic_notificator['is_internal_project_attr']
    daily_working_hours        = Setting.plugin_workload_statistic_notificator['daily_working_hours'].to_f

    users_time = user_notification_settings[:user_time]

    time_top    = []
    time_bottom = []
    time_idle   = []

    unless user_notification_settings[:enabled_users].empty?

      str_arr    = user_notification_settings[:enabled_users].to_s

      str_arr['['] = '('
      str_arr[']'] = ')'

      time_statistic = ActiveRecord::Base.connection.execute("
      SELECT
        users.id                   AS user_id,
        users.login                AS user_name,
        users.firstname            AS firstname,
        users.lastname             AS lastname,
        SUM(ext_spend_hours.hours) AS ext_spend_hours,
        SUM(int_spend_hours.hours) AS int_spend_hours
      FROM users
        LEFT JOIN (SELECT *
                   FROM time_entries
                   WHERE spent_on = CURDATE()
                         AND time_entries.project_id IN (SELECT custom_values.customized_id
                                                         FROM custom_values
                                                         WHERE custom_field_id = (SELECT custom_fields.id
                                                                                  FROM custom_fields
                                                                                  WHERE custom_fields.type = 'ProjectCustomField' AND
                                                                                        custom_fields.name = #{ActiveRecord::Base.sanitize(internal_project_attr)}) AND
                                                                                        custom_values.value != '1')
                  ) AS ext_spend_hours
          ON users.id = ext_spend_hours.user_id
        LEFT JOIN (SELECT *
                   FROM time_entries
                   WHERE spent_on = CURDATE()
                         AND time_entries.project_id IN (SELECT custom_values.customized_id
                                                         FROM custom_values
                                                         WHERE custom_field_id = (SELECT custom_fields.id
                                                                                  FROM custom_fields
                                                                                  WHERE custom_fields.type = 'ProjectCustomField' AND
                                                                                        custom_fields.name = #{ActiveRecord::Base.sanitize(internal_project_attr)}) AND
                                                                                        custom_values.value = '1')
                  ) AS int_spend_hours
          ON users.id = int_spend_hours.user_id
      WHERE users.id IN  #{str_arr}
      GROUP BY users.id
    ").to_a

      time_statistic.each do |item|
        ext_spend_hours = item[4]
        int_spend_hours = item[5]
        case
          when !ext_spend_hours.nil?
            user_id       = item[0].to_s
            user_time     = users_time[user_id].to_f
            required_time = user_time == 0 ? daily_working_hours: user_time
            percentage    = ((ext_spend_hours.to_f / required_time) - 1) * 100
            record        = ["#{item[2]} #{item[3]}", percentage.round(2)]
            if percentage >= 0
              time_top.push(record)
            else
              time_bottom.push(record)
            end
          when !int_spend_hours.nil?
            percentage    = -100
            record        = ["#{item[2]} #{item[3]}", percentage.round(2)]
            time_bottom.push(record)
          else
            record        = ["#{item[2]} #{item[3]}", nil]
            time_idle.push(record)
        end

      end
    end

    {:time_top => time_top, :time_bottom => time_bottom, :time_idle => time_idle}
  end

end
