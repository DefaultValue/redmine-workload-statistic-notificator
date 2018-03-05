require 'httpclient'

module SlackNotificatorHelper

  def send_notification(url, channel, icon, message, attachment=nil)
    message = message
    params  = {
        :text       => message,
        :link_names => 1,
        :username   => 'Redmine',
    }

    params[:channel]     = channel if channel
    params[:attachments] = attachment if attachment

    if icon and not icon.empty?
      if icon.start_with? ':'
        params[:icon_emoji] = icon
      else
        params[:icon_url] = icon
      end
    end

    begin
      client = HTTPClient.new
      client.ssl_config.cert_store.set_default_paths
      client.ssl_config.ssl_version = :auto
      client.post url, {:payload => params.to_json}
    rescue Exception => e
      Rails.logger.warn("cannot connect to #{url}")
      Rails.logger.warn(e)
    end
  end

end
