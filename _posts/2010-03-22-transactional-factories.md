---
layout: post
title: Transactional Factories
author: Tim Harrison
categories: [testing]
topics: []
published: true
homepage: false
sidebar: true
feed: true
description: Using nested database transactions to allow efficient programmatic initialization of ruby unit test data.
links:
- Russ Olsen and David Block give a short description of transactional-factories in their <a href="http://ruby5.envylabs.com/episodes/122-episode-120-october-15th-2010/stories/1051-transactional-factories">Episode 120 on Ruby5</a>
- <a href="https://github.com/heedspin/transactional-factories">View the source on github</a>
---

Transactional-factories is a ruby gem that I created to help speed up my tests.  It uses nested database transactions to allow efficient, programmatic initialization of test data.  In short, it gives each test case a class-level setup callback that is invoked only once.

You can see the source code at [github.com/heedspin/transactional-factories](http://github.com/heedspin/transactional-factories) and download the gem from [gemcutter.org/gems/transactional-factories](http://gemcutter.org/gems/transactional-factories).

### Why?

Many of test scenarios require creation of complex test data and are rather difficult to set up.  Here are some requirements for a testing framework:

- Complex test data - The framework should allow creation of complex test data.
- Cleanliness - Tests should clean up after themselves and not leave behind garbage data. (hint: transactions!)
- Efficiency - Tests should not waste time needlessly recreating test data. (hint: nested transactions!)

<div class="breakout mod">
<h3>How complex is the test data?</h3>
  <p>
One of my projects generates state-mandated reports.  For a glimpse into the level of complexity of state reporting requirements, the reader is invited to visit the California Department Of Education site for <a href="http://www.cde.ca.gov/sp/cd/ci/ccdata.asp">Child Development Data Reporting</a>.  This level of detail drives some of our most complicated test cases.
  </p>
</div>

Transactional-factories address complexity, cleanliness, and efficiency using nested transactions and adding class level setup/teardown callbacks.  Here's how it works: A top level transaction wraps the entire TestCase.  A class-level setup method is called once to allow programmatic creation of test data shared across all tests.  Then each test method is called within a nested transaction that is rolled back to protect the test methods from each other.  The top level transaction is also rolled back to protect the TestCases from each other.  Consider the following test code:

{% highlight ruby %}
require 'transactional_factories'

class MyModelTest < Test::Unit::TestCase
  # Class method called only once to create test data.
  def self.setup
    100.times { MyModel.create }
  end

  # Instance method called before each test method.
  def setup
    MyModel.create
  end
  
  def test_1
    assert_equal 101, MyModel.count
    MyModel.delete_all
    assert_equal 0, MyModel.count
  end

  def test_2
    assert_equal 101, MyModel.count
  end
end
{% endhighlight %}

The sequence of events would be as follows:

1. Top level transaction begin
2. Class level setup()
3. Nested transaction begin
4. Instance method setup()
5. test_1
6. Nested transaction rollback
7. Nested transaction begin
8. Instance method setup()
9. test_2
10. Nested transaction rollback
11. Top level transaction rollback

And that's all there is to it.  You get one class level setup to create test data that's shared across all your tests.  It's programmatic, so you can use your existing model code to create all your complicated dependencies (addressing complexity).  The transactions keep the test methods and test cases from interfering with each other (addressing cleanliness).  It's only run once, so you don't waste time recreating complex data (addressing efficiency).

Check it out! [github.com/heedspin/transactional-factories](http://github.com/heedspin/transactional-factories) and [gemcutter.org/gems/transactional-factories](http://gemcutter.org/gems/transactional-factories).

* * *

### What about ActiveRecord Fixtures?

ActiveRecord fixtures are a clean way to explicitly describe your test data.  And the infrastructure around fixtures in tests is pretty flexible.  With use\_transactional\_fixtures = false, loading a fixture deletes all data in the respective table, so you get cleanliness that way.  With use\_transactional\_fixtures = true, you only have to load your fixtures once, and you use transactions to keep each test method from introducing garbage data.  That gives you efficiency and cleanliness.  However, fixtures don't just address the complexity requirement in my opinion.

By the way, transactional fixtures are not currently implemented to support nested transactions.  I believe this is just a legacy issue since transactional fixtures came before widespread support for nested transactions (through savepoints).  In any case, transactional fixtures must be disabled in order to use transactional-factories.  I think if transactional fixtures are updated to allow nested transactions, the two can coexist.

### Why class-level setup?

I decided to make the transactional-factory callback a class-level method to force the programmer to recognize the non-intuitive object semantics of TestCases.  

The way ruby's Test::Unit::TestCase works is to create a new instance of your test case for each test method.  It's just a strange thing that probably makes sense to people smarter than me.  So in the MyModelTest example above, two instances of MyModelTest would be created; one for test\_1, and another for test\_2.  (Extra credit to the person who can explain why there are actually more than 2 instances of MyModelTest created).

Once consequence of this approach is that test methods can not share instance variables.  You might never notice this if you've been using the instance method setup, since it's called on each instance.  However, since we will only call our transactional-factory setup method once, we have to decide what the scoping should be.  I decided to make it class-level so I wouldn't be tempted to use instance variables.  Class variables will work just fine.

### Questions

Is anyone else approaching this differently?  Do any other test frameworks address this?  E.g, spec?

What are the implications for testing application transactions?
