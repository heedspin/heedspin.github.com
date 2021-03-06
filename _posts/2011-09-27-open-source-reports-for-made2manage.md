---
layout: post
title: "M2MHub: Open Source Reports For Made2Manage"
description: M2MHub is a basic web-based view of the Made2Manage ERP database. It's open source and looking for collaborators.
author: Tim Harrison
published: true
homepage: false
sidebar: true
feed: true
links:
- <a href="http://made2manage.consona.com/">Made2Manage By Consona</a>
- <a href="https://github.com/heedspin/m2mhub">M2mhub on github</a>
- <a href="https://github.com/rails-sqlserver/tiny_tds">TinyTDS on github</a>
- <a href="https://github.com/rails-sqlserver/activerecord-sqlserver-adapter/wiki/Using-TinyTds">TinyTDS and activerecord-sqlserver-adapter</a>
- <a href="http://www.freetds.org/">FreeTDS</a>
- <a href="http://www.erpgraveyard.com/">We must put an end to the need for this website...</a>
---

<p><a href="http://en.wikipedia.org/wiki/Impossible_object"><img src="/images/m2m.jpg" alt="Made2Manage Logo" title="I love that M2M's logo is an example of an impossible object" /></a></p>

I work with a few companies that use the Made2Manage ERP system. In short, building custom reports in Made2Manage (M2M) is difficult. As a software engineer with a lot of web development experience, I find it discouraging how difficult custom reports are for me.  So, after struggling to master M2M, I've finally given up and started writing simple web-based interfaces to the M2M database.  In the hopes of finding others who might be going down this road, I'm providing <a href="https://github.com/heedspin/m2mhub">m2mhub</a> as open source. Though it is not a turn-key application, I would be interested in collaborating with others to make it more useful. 

<div class="breakout mod">
	<h3>The Made2Manage Group on LinkedIn</h3>
  <p>
		I had earlier created an m2mhub google group to provide a forum for anyone to collaborate. However, I've learned that the <a href="http://www.linkedin.com/groups/Made2Manage-1793953">Made2Manage group on LinkedIn</a> has more traffic than anywhere else. With less that 2,000 companies using M2M, the world is not big enough for more than one forum. So please, join the Made2Manage group on linked in.
	</p>

	<p>
		<a href="http://www.linkedin.com/groups/Made2Manage-1793953">http://www.linkedin.com/groups/Made2Manage-1793953</a>
	</p>	
</div>

# M2MHub Overview

At present I have relatively little built. I am not approaching any report in a comprehensive manner. Instead I only write specific interactions that I know will be useful. So, for example, there is no customer search yet. That hasn't been as important as searching the item master.

Strangely, the most powerful part of this app is that I made almost everything clickable. That makes dashboard of recent sales orders (or quotes) a great launching point. You can click on the sales order, or the customer. And from either of those pages, you can click on the item. The initial goal is to make all sales information very easily accessible. This is surprisingly difficult in the M2M app itself.

So here's what I have so far:

 * **Quotes** -
   This is simple crud around quotes. The index page is sorted in reverse chronological order. Quotes are more useful on the home page (dashboard) and on the customer view.
 * **Sales Orders** -
   This is also simple crud around sales orders. Same as quotes, these are more useful in the context of a dashboard or viewing a customer.
 * **Customers** -
   The customer show page is intended to display as much reference information as possible about a single customer. This page should be useful to sales and sales engineers when speaking with a customer. It contains every previous sales order and quote. In particular, having a quick table mapping from customer part number to company-specific part number has been useful to sales engineers.
 * **Items** -
   At this point items page is just a search. It searches by company and vendor part numbers. This has been been useful as a reference for engineers to look up vendor part numbers. It has also been useful for the shipping receiving department to find a company part number when a vendor only includes their own part number in a shipment.
 * **Home Page Dashboard** -
   Right now the home page shows recent sales orders and quotes. This is just the quickest and easiest dashboard I could think of.  

### Connecting to SQLServer

The hardest part about any of this is just connecting your Rails app to a SQLServer database.  If you get discouraged, just remember this: "You can DO IT! Victory will be sweet."  I have a few more details in the m2mhub github readme. But a good starting point is here: <a href="https://github.com/rails-sqlserver/tiny_tds">tiny_tds</a> and <a href="https://github.com/rails-sqlserver/activerecord-sqlserver-adapter">activerecord-sqlserver-adapter</a>.

### Basic Architecture

Our M2M databases run in our building. I believe this is a typical setup for M2M. So I setup a small Ubuntu server behind our firewall and give it a public IP address. Though I'm a big believer in the cloud, I don't see another way to do this. I feel ok opening up HTTPS access to my Ubuntu box. I would be much more nervous opening up access to our M2M database to some web app in the cloud.  

### Future Plans

I'm planning on doing something with RMA's and integrating with Lighthouseapp.  I'm also planning on doing a custom shipping report. It would be great to have other people writing some custom reports so we could share code. Join me!

