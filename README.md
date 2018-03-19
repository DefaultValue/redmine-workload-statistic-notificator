# Workload Statistic notificator plugin

Plugin provides functionality for sending workload statistics notifications to Slack 

## Installation

1. Clone this plugin to your Redmine plugins directory:

```bash
user@user:/path/to/redmine/plugins$ git clone git@github.com:DefaultValue/redmine-workload-statistic-notificator.git workload_statistic_notificator
```

2. Install `httpclient` dependency, by running:

```bash
user@user:/path/to/redmine/plugins/workload_statistic_notificator$ bundle install
```
   
3. Restart Redmine to check plugin availability and configure its options.

4. Set up cron task:
```
*   *    *    *    *    path/to/redmine/bin/rake send_day_workload_statistic RAILS_ENV=production
``` 
