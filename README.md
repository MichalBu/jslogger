JSLogger - Log errors and events from your Javascript app
========

##Why to use it?

* Keep track of your clientside code erros in production so you can debug them later.
* Track any user events on your site from your heavy Javascript app. (similar to Google Analytics events)
* Investigate what browser platforms generate more errors for your app.
* Send the logs and events on our site so your servers don't get overloaded.
* Analyze and manage your logs from our management interface, anywhere, anytime.

##How to use it?

* Include the script in your web page, preferably before any other script:
```html
<script type="text/javascript" src="http://jslogger.com/jslogger.js"></script>
```
* Start monitoring errors:
```html
<script type="text/javascript">window.jslogger = new JSLogger();</script>
```
* Watch your logs on our site.

##How to track?

All Javascript errors in your site will be logged to our server by default. But you can also log and track events by your own.

###Logs

To log errors or other types of notifications use the `.log(data)` function
```javascript
jslogger.log("I am an exception")
```
```javascript
jslogger.log({exception: {name: "SignupFail", message: "The signup request failed."}})
```

###Events

To log special events use the `.event(data)` function
```javascript
jslogger.event("The signup button was clicked.")
```
```javascript
jslogger.event({signup: {from: "Header red button"}})
```

##Options

If you don't want to send logs to the server in development mode, set track option to `false`:
```javascript
new JSLogger({track: false});
```
If you don't want to track the errors in your site, set logWindowErrors to `false`:
```javascript
new JSLogger({logWindowErrors: false});
```

##How to apply?

Our tool is still in BETA version. You can register here: [http://jslogger.com:5000/manage][]. For other question please send an e-mail to [support@jslogger.com][].
For quick questions you can always ping us on Twitter - [@jslogger][] or twitt about how awesome is JSLogger - [#jslogger][].
Like us on [Facebook][] and become a part of the [JSLogger community][].

[http://jslogger.com:5000/manage]: http://jslogger.com:5000/manage
[support@jslogger.com]: mailto:support@jslogger.com?subject=JSLogger.com%20support
[@jslogger]: https://twitter.com/intent/tweet?text=@jslogger
[#jslogger]: https://twitter.com/intent/tweet?text=%23jslogger%20is%20awesome!
[Facebook]: http://facebook.com/jslogger
[JSLogger community]: http://facebook.com/jslogger
