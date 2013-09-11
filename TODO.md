# Simple form TODO

* Convert all forms into simple forms
* Add alchemy wrapper (like foundation wrapper)
  * Rename error class
  * add submit button wrapper
* Convert ^ style Error messages
* Convert all controller actions from render_errors_or_redirect into Rails-style error handling, or refactor render_errors_or_redirect
  * remove render_remote_errors calls in elements_controller#create and pages_controller#update
* Use partials in pages forms
* Handle redirects in ajax forms
  * do_redirect_to should close dialog properly
