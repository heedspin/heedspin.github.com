---
layout: post
title: ActiveHash and SuperEnum!
author: Tim Harrison
published: true
homepage: false
sidebar: true
feed: true
description: Ruby ActiveHash gem extended to make the enumerations more readable.
links:
- <a href="https://github.com/zilkey/active_hash">Active Hash on Github</a>
---

Jeff Dean's <a href="https://github.com/zilkey/active_hash">ActiveHash</a> is a great gem for status-type associations.  In this post I show how I extend ActiveHash to improve readability.

A NewsItem model might belong to Status to indicate values like Published, Draft, and Deleted.  ActiveHash lets you do ActiveRecord type associations, but without having to hit the database.

{% highlight ruby %}
class Status < ActiveHash::Base
  include ActiveHash::Enum
  self.data = [
    {:id => 1, :name => 'Draft'},
    {:id => 2, :name => 'Published'},
    {:id => 3, :name => 'Deleted'}
  ]
  enum_accessor :name
end

# == Schema Information
#
# Table name: news_items
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  body       :text
#  status_id  :integer(4)
#  created_at :datetime
#  updated_at :datetime
#
class NewsItem < ActiveRecord::Base
  belongs_to :status
  scope :not_deleted, 
        :conditions => [ 'news_items.status_id != ?', 
                         Status::DELETED.id ]
end
{% endhighlight %}

NewsItem is a standard ActiveRecord model, but notice that Status inherits from ActiveHash::Base.  Status will not touch the database, but you can use it like a regular ActiveRecord model.  E.g., in your controllers and models:

{% highlight ruby %}
news_item = NewsItem.create(:status => Status::DRAFT)
if news_item.status == Status::PUBLISHED
  # ...
end
{% endhighlight %}

And in your formtastics, you can treat Status like you would an ActiveRecord model:

{% highlight ruby %}
  f.input :status, :collection => Status.all
{% endhighlight %}

In the above examples I'm using the ActiveHash::Enum module to magically add the DRAFT, PUBLISHED, and DELETED enumerations.  Super handy.  However, I have to leave my mark on everything, so I extended ActiveHash a little.  Instead of Status::PUBLISHED, I like to write Status.published.  And I'd also like to be able to easily test the value of a Status instance with shorthand such as @status.published? and @status.deleted?:

{% highlight ruby %}
  @news_item = NewsItem.create(:status => NewsItem.draft)
  # ...
  if @news_item.status.draft?
    # ...
  elsif @news_item.status.published?
    # ...
  elsif @news_item.status.deleted?
    # ...
  end
{% endhighlight %}

To do the above I create a little helper module in RAILS_ROOT/lib/active_hash/super_enum:

{% highlight ruby %}
module ActiveHash
  module SuperEnum
    def self.included(base)
      base.send(:include, Enum)
      base.extend(Methods)
    end

    module Methods
      def insert(record)
        super
        loud = constant_for(record.attributes[@enum_accessor])
        return nil if loud.blank?
        quiet = loud.downcase
        self.class_eval <<-RUBY
        def #{quiet}?
          self.id == #{loud}.id
        end
        class << self
          def #{quiet}
            #{loud}
          end
        end
        RUBY
      end
    end
  end
end
{% endhighlight %}

Now in my Status module I do this:

{% highlight ruby %}
require 'active_hash/super_enum'
class Status < ActiveHash::Base
  include ActiveHash::SuperEnum
  self.data = [
    {:id => 1, :name => 'Draft'},
    {:id => 2, :name => 'Published'},
    {:id => 3, :name => 'Deleted'}
  ]
  enum_accessor :name
end
{% endhighlight %}

Thus in your controllers and models:

{% highlight ruby %}
news_item = NewsItem.create(:status => Status.draft)
if news_item.status.published?
  # ...
end
{% endhighlight %}

Functionally, SuperEnum is the same as ActiveHash::Enum.  SuperEnum just shouts a little less for those of us with sensitive eyes.  In any case, you should all be using ActiveHash.  It saves you from writing useless database migrations, db initialization tasks, and it probably saves trees.

What are other people using for Status-type associations?