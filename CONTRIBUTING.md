# How to contribute

OMG I am so excited that you're reading this. Being a non-profit, we need volunteer developers to help OpenGovernment come to fruition.

So, where should you dive in? If you haven't already, come find us in IRC. We want you working on things you're excited about.

Here are some important resources:

  * Mailing list: Join our [developer list](http://groups.google.com/group/opengovernment/).
  * IRC: Find us in chat.freenode.net channel [#opengovernment](irc://chat.freenode.net/opengovernment).
  * [Pivotal Tracker](http://pivotaltracker.com/projects/64842) is our day-to-day project management space
  * Bugs? [Lighthouse](https://participatorypolitics.lighthouseapp.com/projects/47665-opengovernment/overview) is where to report them

## Testing

We have a handful of Cucumber features, but most of our testbed consists of RSpec examples. Please write examples for new code you create.

## Submitting changes

When you have an update for us, please send a [GitHub Pull Request](http://help.github.com/pull-requests/) to us with a clear list of what you've done. When you send a pull request, we will love you forever if you include RSpec examples. We can always use more test coverage. Please follow our coding conventions (below) and make sure all of your commits are atomic (one feature per commit).

Always write a clear log message for your commits. One-line messages are fine for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    > 
    > A paragraph describing what changed and its impact."

## Coding conventions

Start reading our code and you'll get the hang of it. We optimize for readability:

  * We indent using two spaces (soft tabs)
  * We use HAML for all views
  * We avoid logic in views, putting HTML generators into helpers
  * We ALWAYS put spaces after list items and method parameters (`[1, 2, 3]`, not `[1,2,3]`), around operators (`x += 1`, not `x+=1`), and around hash arrows.
  * This is open source software. Consider the people who will read your code, and make it look nice for them. It's sort of like driving a car: Perhaps you love doing donuts when you're alone, but with passengers the goal is to make the ride as smooth as possible.

Thanks,
Carl Tashian, Participatory Politics Foundation
