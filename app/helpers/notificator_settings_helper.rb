module NotificatorSettingsHelper

  def get_project_custom_attributes
    attrs = ActiveRecord::Base.connection.execute("
      SELECT
          custom_fields.name
      FROM
          custom_fields
      WHERE
          custom_fields.type = 'ProjectCustomField'
              AND custom_fields.field_format = 'bool';
    ")

    attrs.to_a
  end

  def get_all_active_users
    User.where(status: 1).order(:firstname => :asc).order(:lastname => :asc).all
  end

  def get_user_notification_settings
    user_ids     = []
    users_time   = {}
    all_settings = Setting.plugin_workload_statistic_notificator
    all_settings.each do |skey, svalue|
      if skey.to_s['user_enabled'] && svalue.to_s == 'on'
        user_id                  = skey.dup
        user_id['user_enabled_'] = ''
        user_id_key              = "user_#{user_id}"
        user_ids.push(user_id)
        users_time[user_id] = all_settings[user_id_key]
      end
    end
    {:enabled_users => user_ids, :user_time => users_time}
  end

end
