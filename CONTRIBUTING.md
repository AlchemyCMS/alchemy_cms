Alchemy CMS is an open source project and we encourage contributions. Please read these
contributors guidelines and our code of conduct before contributing.

## Filing an issue

When filing an issue on the Alchemy CMS project, please provide these details:

* A comprehensive list of steps to reproduce the issue.
* What you're *expecting* to happen compared with what's *actually* happening.
* The version of Alchemy *and* the version of Rails.
* Your application's complete Gemfile, as text (*not as an image*)
* Any relevant stack traces ("Full trace" preferred)

In 99% of cases, this information is enough to determine the cause and solution
to the problem that is being described.

Please remember to format code using triple backticks (\`\`\`) so that it is neatly
formatted when the issue is posted.

## Pull requests

We gladly accept pull requests to fix bugs and, in some circumstances, add new
features to Alchemy.

NOTE: Please discuss new features at the public Alchemy Trello board
and/or the Alchemy discussion board, before sending a pull request.

Here's a quick guide:

1. Fork the repo.

2. Run the tests. We only take pull requests with passing tests, and it's great
to know that you have a clean slate:

        $ bundle exec rake

3. Create new branch then make changes and add tests for your changes. Only
refactoring and documentation changes require no new tests. If you are adding
functionality or fixing a bug, we need tests!

4. Push to your fork and submit a pull request. If the changes will apply cleanly
to the latest stable branches and main branch, you will only need to submit one
pull request.

5. If a PR does not apply cleanly to one of its targeted branches, then a separate
PR should be created that does. For instance, if a PR applied to main & 2.7-stable but not 2.8-stable, then there should be one PR for main & 2.7-stable and another, separate PR for 2.8-stable.

At this point you're waiting on us. We like to at least comment on, if not
accept pull requests. We may suggest some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted,
taken straight from the Ruby on Rails guide:

* Use Rails idioms and helpers
* Include tests that fail without your code, and pass with it
* Update the documentation, the surrounding one, examples elsewhere, guides,
  whatever is affected by your contribution

Please follow these syntax guides:

* Two spaces, no tabs.
* No trailing whitespace. Blank lines should not have any space.
* Add a new line at the end of every file.
* Prefer `&&`/`||` over `and`/`or`.
* `MyClass.my_method(my_arg)` not `my_method( my_arg )` or `my_method my_arg`.
* `a = b` and not `a=b`.
* `a_method { |block| ... }` and not `a_method { | block | ... }`
* Follow the conventions you see used in the source already.
* `->` symbol over lambda
* This `{a: 'b'}` is a hash, this `{ a + b }` is a block.
* Ruby 1.9 hash syntax over Ruby 1.8 hash syntax

And in case we didn't emphasize it enough: we love tests!
