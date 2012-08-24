---
layout: post
title: "Using Any File Format for the Made2Manage CAD Images"
description: Made2Manage lets you attach CAD drawings to the item master. This trick lets you attach any file format to the item master.
author: Tim Harrison
published: true
homepage: false
sidebar: true
feed: true
links:
- <a href="http://made2manage.consona.com/">Made2Manage By Consona</a>
- <a href="http://groups.google.com/group/m2mhub?hl=en">Join my M2M Mailing List</a>
---

The Made2Manage (M2M) ERP system lets you attach 3 CAD Images to your item master. Like so:

<p>
	<img src="/images/m2m-cad-images/cad-images-on-item-master.png" />
</p>

These image locations get copied to jobs in production. Like so:

<p>
	<a href="/images/m2m-cad-images/cad-images-in-job.png"><img src="/images/m2m-cad-images/cad-images-in-job.png" width="500"/></a>
</p>

The problem is that M2M will try to open these CAD Images using a single application that you configure in your user management. The assumption is that we will only put CAD files there and so we just need to tell M2M where our CAD program is. 

We want to put PDFs and images and CAD files there.  If you've read this far, you probably do too.  So here's what we put in our User Management:

<p>
	<img src="/images/m2m-cad-images/user-management.png" />
</p>

We've created a little start.bat script that will launch whatever we want.  You ready for the brilliance of start.bat?  Brace yourself.  Seriously...

<p>
	<img src="/images/m2m-cad-images/start-bat.png" />
</p>

Yup.  It's that awesome.  The entire file contents are "%1" without the quotes.  I'm no windows expert, but I think it's the equivalent of just double-clicking the file.  Let windows figure out what app to launch to view your file.  

That's all.  I hope this helps.