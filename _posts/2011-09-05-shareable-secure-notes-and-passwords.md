---
layout: post
title:  Shareable and Secure Notes and Passwords
description: Using encfs, Notational Velocity, and Dropbox to keeps notes that are encrypted and shareable.
author: Tim Harrison
published: true
homepage: false
sidebar: true
feed: true
links:
- <a href="http://forums.dropbox.com/topic.php?id=15065">Pitfalls</a>
- <a href="http://wiki.dropbox.com/TipsAndTricks/IncreasePrivacyAndSafety">Dropbox Says</a>
- <a href="http://techieblurbs.blogspot.com/2010/02/howto-replace-filevault-with-encfs.html">Encfs Help</a>
---

My wife and I share files via dropbox. I've just set us up using <a href="http://www.arg0.net/encfs">encfs</a>, <a href="http://notational.net/">Notational Velocity</a>, and <a href="dropbox.com">Dropbox</a> to keep important files (with passwords etc) both encrypted and easy browse on our macs. I don't think it will last, and I don't recommend others try setting this up. But if you must, here's what I have done.

## Install encfs

We're on Snow Leopard and Lion. Installing encfs was not easy. I prefer DMG installs. When I can't find those, I first try homebrew. Homebrew has a recipe for encfs, but it wasn't playin. Something about "dyld: Library not loaded: /usr/local/lib/libintl.8.dylib". I had to fall back to macports.

  sudo port install encfs

The underlying magic that lets developers play with the macos filesystem is in flux. You've got the MacFUSE incumbant, and new Fuse4X and OSXFuse on the scene. I think MacFUSE is end of life. (There are also some alternate builds of macfuse out there). They're all in various stages of support of OS X Lion. It's confusing.

I think the macport of encfs uses Fuse4X. I have some stability issues (below) that I suspect are from Fuse4X. But I'm happy it mostly works.

Once installed I recommend playing around with encrypted folders by following <a href="http://www.arg0.net/encfsintro">encfs' extended intro</a>. In the end you're going to do something like this:

  encfs /Users/myusername/Dropbox/.encrypted /Users/myusername/unencrypted

If you don't have a Dropbox folder you're doomed. You can't be helped.

We're going to tell Notational Velocity to store it's notes in the unencrypted folder. If you're confused about how all the encryption works, my suggestion is to just play with it. It'll make sense when you see it.

## Notational Velocity

Notational Velocity is a note taking app. Go to the website and read all about it. Like many others, I use <a href="http://brettterpstra.com/project/nvalt/">the nValt fork</a>. No reason, really. I just follow the cool kids.

Go install it and play around. Make sure to configure it to store separate txt files that are NOT encrypted. You'll see what it's doing pretty quick. When you're ready to party, configure Notation Velocity to store it's text files in your unencrypted folder.

By the by, it's not documented well, but you can import tab separated files into Notation Velocity. The first column is the title. The remaining columns are the body on a new lines. So if you have a bunch of existing notes you want to import, you can create a .tsv file and do them in one swoop. Or you could just create a bunch of text files and put them in your unencrypted folder.

## The Bootstrap Challenge

One of the challenges with this whole thing is that you need encfs to mount your unencrypted folder *before* Notational Velocity starts up. If NV gets its grubby hands in your unencrypted folder before encfs has started, then NV will create default files and just be confused. And encfs needs its password, so this step may or may not need to be interactive.

Some folks have tried using a mac os login hook. I played around with launchd LaunchAgents, which are pretty cool. In the end, those approaches scare me. If something is awry with your setup, your login is hosed. You have to take extreme measures to halt the normal login process.

Instead, I chose to use the greatest technology ever developed by mankind: AppleScript. That's right. Fear me. I really just wanted to learn a little bit about AppleScript. It's a horrible language. But it's working, so whatever.

All it does is prompt for a password, mount your encrypted folder using encfs, and then launch Notation Velocity (or nValt in my case). All the other code in there is basic error checking to make sure it doesn't try to mount the folder if it's already there. I tried to make it fancy with KeyChain, but failed on Lion.

{% highlight applescript %}
on run
  set home_directory to (system attribute "HOME")
  set encrypted_folder to home_directory & "/Dropbox/.encrypted"
  set unencrypted_folder to home_directory & "/unencrypted"
  if (fileExistsAtPath(home_directory & "/unencrypted/.mount_verification")) then
    # Already Mounted
  else
    if not (directoryExistsAtPath(encrypted_folder)) then
      display dialog "Can not find Dropbox folder"
    else
      if not (directoryExistsAtPath(unencrypted_folder)) then
        display dialog "Can not find unencrypted folder"
      else
        set user_password to getPassword("Encrypted Folder")
        do shell script "echo " & user_password & " | /opt/local/bin/encfs -S " & encrypted_folder & " " & unencrypted_folder
      end if
    end if
  end if
  tell application "nvALT" to activate
end run

# I originally wanted this to look into keychain before prompting. However, I was
# only able to get it working on Snow Leopard. Keychain Scripting is gone on Lion.
# The interwebs say to use the security command line. That works, but throws noisy 
# errors if the password isn't stored there. So in the end, I'm removing support for 
# keychain. Thanks apple.
on getPassword(key_name)
  set password_result to text returned of (display dialog key_name & " Password" default answer "" with hidden answer)
  return password_result
	
  #local password_result
  #try
  # This only works on Mac OS Lion
  # tell application "Keychain Scripting"
  #	tell keychain "login.keychain"
  #		get {password} of (first key whose name is key_name)
  #		set password_result to result
  #	end tell
  # end tell
  # This works but throws error if not in keychain.
  # set password_result to (do shell script "security find-generic-password -ga 'Magic Box' 2>&1 > /dev/null | cut -d'\"' -f2")
  #on error theErroer
  #	set password_result to missing value
  #end try

  #if (password_result is missing value) then
  #	set password_result to text returned of (display dialog key_name & " Password" default answer "" with hidden answer)
  #end if

  #return password_result
end getKeychainPassword

on directoryExistsAtPath(path)
  local directoryExists -- boolean	
  try
    set result to (do shell script "if [ -d " & quoted form of path & " ] ; then exit 0 ; else exit 1 ; fi")
    set directoryExists to true
  on error theError
    set directoryExists to false
  end try
  return directoryExists
end directoryExistsAtPath

# Credit: Mikey-San from http://hintsforums.macworld.com/archive/index.php/t-90226.html.
on fileExistsAtPath(path)
  local fileExists -- boolean	
  try
    set result to (do shell script "if [ -f " & quoted form of path & " ] ; then exit 0 ; else exit 1 ; fi")
    set fileExists to true
  on error theError
    set fileExists to false
  end try
  return fileExists
end fileExistsAtPath
{% endhighlight %}

I compile this into an Application that I can install on all relevant computers. The first time it's launched, it prompts for a password and mounts encfs. If you never need it, you don't waste time mounting it.

<div class="breakout mod">
<h3>Why We Probably Will Not Use It</h3>

<p>After all this work I'm still not sure if we will use it long term.  There are a couple of drawbacks:</p>

<ul>
	<li>encfs can hang my mac like it just don't care.  If I mount an encrypted drive, unmount it, and then try to mount again? Good night. Press and hold the power button. You're d. u. n. done. Maybe it's the underlying fuse library. Who knows. But if we find we can not avoid that sequence then I'll unuinstall it.</li>
	
	<li>Multiple machines editing the same notes does not work with Notational Velocity.  While running, NV does not deal well with notes changing out from underneath it. If someone else adds a new note, that's ok. But even just viewing a note will save it. So if I'm viewing a note while my wife is editing it, it's a race to the finish. Changes will be lost. Maybe you can recover them from a dropbox version. Or maybe we have a "convention" of never editing secure notes. We can only add new versions and delete the old ones. Did you just feel icky? Yeah, me too.</li>
	
	<li>It's sad to only use Notational Velocity for secure notes. I like the app so much, I wish I could use it on unencrypted notes. I may eventually point NV at an unencrypted dropbox folder and just use a text editor to manage the secure notes.</li>
</ul>
</div>

## Questions?

I know I left out a bunch of details. How to configure Notational Velocity, what's the .mount_verified file, etc. This post is mostly to commiserate with others feeling the encfs + dropbox pain. If you really want to feel the thunder and you think I can help, feel free to ask questions.
