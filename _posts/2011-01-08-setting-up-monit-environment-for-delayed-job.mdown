---
layout: post
title: Setting up monit's environment to start and stop delayed_job
description: Getting monit to start and stop delayed_job is a giant pain, mostly because of environment problems.  In this post I explain how I make it work.
author: Tim Harrison
published: true
homepage: false
sidebar: true
feed: true
links:
- <a href="https://github.com/peregrinator">Bob Burbach / peregrinator</a> wrote the capistrano recipe.
- <a href="http://mmonit.com/monit/">monit</a>
- <a href="https://github.com/tobi/delayed_job">delayed_job</a>
---

<div class="breakout mod">
	<p>Update March 18, 2012:</p>
	<h3>Using Rails 3?</h3>
	<p>I'm using Rails 3.1.3.  To get DJ working I've had to stick with delayed_job 2.1.4.  The 3.0.1 build results in "undefined method `before_fork' for nil:NilClass".  If you google around enough you'll find the reasons why.  If you're like me and have other things to do, just stick with 2.1.4 for now.</p>
	<p>Thanks <a href="http://www.jonathandean.com/2011/08/delayed_job-in-rails-3/">jonathan dean</a>.</p>
</div>


I use <a href="http://mmonit.com/monit/">Monit</a> to keep <a href="https://github.com/tobi/delayed_job">delayed_job</a> running.  Getting monit to start and stop delayed_job is a giant pain, mostly because of environment problems.  In this post I explain how I make it work.

## Monit

First off, install monit.  It's pretty easy.  But remember to set startup=1 in /etc/default/monit.  Also, I recommend adding your email as an alert recipient in /etc/monit/monitrc.

To tell monit how to start and stop delayed_job, I create /etc/monit.d/check_process_delayed_job with the contents below.  Check monit docs for details around my alert and restart settings.

{% highlight bash %}
check process myapp_delayed_job with pidfile /path/to/myapp/tmp/pids/myapp_delayed_job.pid
  start program = "/bin/bash /path/to/myapp/script/monit_delayed_job.sh start"
    as uid wei and gid wei
  stop program =  "/bin/bash /path/to/myapp/script/monit_delayed_job.sh stop"
    as uid wei and gid wei
  if cpu > 60% for 2 cycles then alert
  if cpu > 80% for 5 cycles then restart
  if totalmem > 200.0 MB for 5 cycles then restart
  if 3 restarts within 5 cycles then timeout
  group background_tasks
{% endhighlight %}

## monit_delayed_job.sh

Notice that it's starting and stopping delayed_job through an sh script.  My rails_root/script/monit_delayed_job.sh is below.  It does two important things: loading /etc/profile, and logging.  But the greatest of these is logging!

All the output of monit_delayed_job.sh is logged to log/monit_delayed_job.log, so you can see if you have any environmental errors.  Otherwise monit will swallow the errors and you'll go mad.  We don't want that.

BTW, you can see I'm using bundle exec.  You can easily change the last line of the sh script to start delayed_job however you like.

{% highlight bash %}
#!/usr/bin/env bash                                                                                                                                                  

if [ $# -lt 1 ] ; then
    echo "Usage:   " $0 " <start | stop> "
    exit 1
fi

action=$1

script_location=$(cd ${0%/*} && pwd -P)
cd $script_location/..
rails_root=`pwd`

if [ -f "/etc/profile" ]; then
  . /etc/profile
fi

logfile=$rails_root/log/monit_delayed_job.log
echo "-----------------------------------------------" >> $logfile 2>&1
echo "Running bundle exec ./script/delayed_job $action" >> $logfile 2>&1
echo `date` >> $logfile 2>&1
echo `env` >> $logfile 2>&1

bundle exec ./script/delayed_job $action >> $logfile 2>&1
{% endhighlight %}

## /etc/profile

In /etc/profile somewhere I set PATH and RAILS_ENV.  Obviously, you should change these accordingly.  Keeping the path and environment settings in /etc/profile allows me to setup hosts differently.

{% highlight bash %}
export PATH="/usr/local/sbin:/usr/sbin:/sbin:/usr/local/ruby-enterprise/bin:$PATH"
export RAILS_ENV=production
{% endhighlight %}

## Capistrano

I use capistrano to deploy.  My delayed_job.rb recipe is below.  It's pretty straight forward.

{% highlight ruby %}
Capistrano::Configuration.instance(:must_exist).load do
  namespace :delayed_job do
    desc "Start delayed_job daemon"
    task :start do
      alert_user("Starting delayed job using #{use_monit_for_delayed_job ? 'monit' : 'script/worker'}")
      
      if use_monit_for_delayed_job
        sudo "monit start #{monit_service_name}"
      else
        run "cd #{current_path} && RAILS_ENV=#{rails_env} script/worker start"
      end
    end
    
    desc "Stop delayed_job daemon"
    task :stop do
      alert_user("Stopping delayed job using #{use_monit_for_delayed_job ? 'monit' : 'script/worker'}")
      
      if use_monit_for_delayed_job
        sudo "monit stop #{monit_service_name}"
      else  
        run "cd #{current_path} && RAILS_ENV=#{rails_env} script/worker stop"
      end
    end
    
    desc "Restart delayed_job daemon"
    task :restart do
      alert_user("Restarting delayed job using #{use_monit_for_delayed_job ? 'monit' : 'script/worker'}")
      
      if use_monit_for_delayed_job
        sudo "monit restart #{monit_service_name}"
      else
        run "cd #{current_path} && RAILS_ENV=#{rails_env} script/worker restart"
      end
    end
  end  
end
{% endhighlight %}

To enable monit in the recipe above, I set these two things in my deploy.rb:

{% highlight ruby %}
namespace :delayed_job do
  set :use_monit_for_delayed_job, true
  set :monit_service_name, 'myapp_delayed_job'
end
{% endhighlight %}

## Logrotate

Rotating logs is fun.  Do it.  Here's my /etc/logrotate.d/myapp file.  

{% highlight bash %}
/path/to/myapp/log/*.log {
  weekly
  missingok
  rotate 100
  compress
  copytruncate
  delaycompress
  sharedscripts
}
{% endhighlight %}

## Victory

Simple enough, eh?  I hope this helps you get it working.