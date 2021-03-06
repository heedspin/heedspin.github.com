---
layout: post
title: Archive Email Before Deleting a Google Apps User 
description: Before deleting a google apps user, download emails with Thunderbird and archive the profile directory.
author: Tim Harrison
published: true
homepage: false
sidebar: true
feed: true
links:
- <a href="http://blog.workingradio.com/">Read Larry</a>
---

<p>
<a href="http://lxdinc.com">We (at lxd)</a> are using google apps for business.  When someone leaves the company, we'd like to archive all their emails so that we can access them later without paying google $50/year per user. It's pretty easy with Thunderbird. In short, we just download all the user's emails and zip up the Thunderbird profile directory.  In long...
</p>

### Change password to archive_user@mycompany.com

This should probably be part of your normal steps after an employee leaves. Since we're going to archive the emails, we want to just change the password instead of deactivating the account.  <a href="http://www.google.com/support/a/bin/answer.py?answer=33319">Google instructions for changing a user's password</a>.

### Rename and Forward user@mycompany.com

As a google domain administrator you need to rename user@mycompany.com to something like archive_user@mycompany.com.  <a href="http://www.google.com/support/a/bin/answer.py?answer=182084">Google Instructions For Renaming A User</a>.

That's going to create a nickname/alias for user@mycompany.com.  So scroll down and delete that nickname.  Then go to another user (e.g., new employee) and add an alias for user@mycompany.com.  That way you don't lose any emails intended for the account you are going to delete.

### Make sure POP/IMAP is enabled

You need to login to the archive_user@mycompany.com account, go to mail settings, "Forwarding and POP/IMAP", and make sure that "Enable POP for all mail (even mail that's already been downloaded)" is set.  <a href="http://mail.google.com/support/bin/answer.py?answer=13273">These Google Instructions are pretty close</a>.

### Export all the user's emails

Install a fresh copy of Thunderbird and connect it to archive_user@mycompany.com with your new password.  Thunderbird is pretty easy to setup.  I have confidence that you can do it!

It's best to do this in an empty Thunderbird profile.  If you already use Thunderbird, you can <a href="http://support.mozillamessaging.com/en-US/kb/using-multiple-profiles">Setup Multiple Profiles in Thunderbird</a>.

Once you kick off Thunderbird, it will take a long time to download everything.  Just let Thunderbird sit there for many hours.  I leave it overnight.  I don't really know how to tell when it's done other than when it just seems to stop downloading more.  :-)

### Zip up the profile directory

Exit Thunderbird and <a href="http://kb.mozillazine.org/Profile_folder_-_Thunderbird">find your Thunderbird profile directory</a>.  You can just zip that profile directory and put the zip file on a DVD or where you want to store it permanently.  On the same DVD, it's a good idea to include installers for the version of Thunderbird you used to export the emails.  I include a windows and mac installer.

### Accessing archived emails

Should the day come when you need to go find an old email, it's pretty easy.  I just install a fresh copy of Thunderbird (from the DVD).  I've done this on both Windows and Mac. When it asks to enter an email address, just cancel.  Depending on your operating system, it may complain about a failed install because you cancelled.  Ignore that.  What you just did was create an empty profile.

Exit Thunderbird, and find that empty profile directory.  Unzip your DVD copy the Thunderbird profile and copy the contents into the new empty profile directory.  Then just start Thunderbird.  All the archived emails should be there in their searchable glory.  I've even exported from Windows and opened them from Mac.  Thunderbird's profile directory seems to be nicely portable.

BTW, there's a mozbackup program out there that makes backing up a profile super easy.  But that program does not run on mac, so I vote no.  Just zip up the profile directory.  Sorry mozbackup.

### Delete the old accounts

Before deleting a user I recommend verifying that you have access to the archived emails. Also, you'll want to <a href="http://www.google.com/support/a/bin/answer.py?answer=1247799">transfer ownership of any google docs</a> and <a href="http://www.google.com/support/calendar/bin/answer.py?answer=37082">share calendars</a>.  Once you delete the archive_user@mycompany.com account, any Thunderbirds will start complaining about failed authentication.  Just go into Thunderbird's server settings and uncheck everything.  That'll keep it from trying to connect to an account that doesn't exist.

### Will My Archive Work 10 Years From Now?

No.  Whatever OS you're exporting on now will be end of life eventually.  Your archived installers will not work.  And the latest version of Thunderbird will have no idea how to load that profile directory.  This approach is good for a few years.  If you need to guarantee access for many years you should really just keep the google accounts and deactivate them.  Pay the $50/year and thank your lucky clouds.

## Feedback welcome

Let me know if you approach this differently...

