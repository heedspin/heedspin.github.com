---
layout: post
title: Configuring delayed_job Logging
description: Here's how I configure delayed_job to log to a separate file
author: Tim Harrison
published: true
homepage: false
sidebar: true
feed: true
links:
- <a href="https://github.com/tobi/delayed_job">tobi / delayed_job</a> on the githubs.
---

I use <a href="https://github.com/tobi/delayed_job">delayed_job</a> to run things when you least expect it!  I want my web request to be logged to RAILS_ROOT/log/production.log and my delayed_job work to be logged to RAILS_ROOT/log/production_delayed_job.log.  Here's how I configure delayed_job to log to a separate file.

## RAILS_ROOT/config/delayed_job_config.rb

I drop this into my RAILS_ROOT/config/delayed_job_config.rb.

{% highlight ruby %}
Delayed::Worker.logger = 
  ActiveSupport::BufferedLogger.new("log/#{Rails.env}_delayed_jobs.log", Rails.logger.level)
Delayed::Worker.logger.auto_flushing = 1
if caller.last =~ /.*\/script\/delayed_job:\d+$/
  ActiveRecord::Base.logger = Delayed::Worker.logger
end
{% endhighlight %}

The auto_flushing=1 addresses some issue with delayed_job assuming it's getting a buffered logger.  <a href="https://github.com/collectiveidea/delayed_job/issues/issue/47">You can read about it here</a>.

The caller.last parsing is the hack I put in to get all my application logging into the delayed job log.  delayed_job_config.rb is loaded by your web app as well as by the delayed job processes.  This conditionally hijacks the ActiveRecord::Base.logger if we're running in the delayed_job daemon.

An important part of getting this to work is to use ActiveRecord::Base.logger correctly in your models.

{% highlight ruby %}
class MyModel < ActiveRecord::Base
  def mymethod
    logger.info <<-TEXT
      This will get written to log/production.log
      when called by a web request, but
      it will be written to log/production_delayed_job.log
      when called in a delayed job.
    TEXT
    Rails.logger.info "Always goes to log/production.log"
  end
end
{% endhighlight %}

## Questions

 * Is there a better way to detect that I'm running in the delayed_job daemon?
 * Is there a better logger than the BufferedLogger and auto_flushing=1?
