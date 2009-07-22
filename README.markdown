Apple Push Notification
=====================

This plugin helps you use the Apple Push Notification system.

Converting Your Certificate
---------------------------

Once you have the certificate from Apple for your application, export your key
and the apple certificate as p12 files. Here is a quick walkthrough on how to do this:

1. Click the disclosure arrow next to your certificate in Keychain Access and select the certificate and the key. 
2. Right click and choose `Export 2 items...`. 
3. Choose the p12 format from the drop down and name it `cert.p12`. 

Now covert the p12 file to a pem file:

    $ openssl pkcs12 -in cert.p12 -out apple_push_notification.pem -nodes -clcerts

Put `apple_push_notification.pem` in config/

Installing
----------

Simply run the following commands to add apple-push-notification as a submodule to your repo, a plugin to your rails app, and install it.

    $ cd ~/my_rails_app
    $ script/plugin install git://github.com/samsoffes/apple_push_notification.git
    $ rake apn:migrate

Example
-------

*Note: the spaces in `device_token` are optional.*

    $ ./script/console
    >> a = ApplePushNotification.new
    >> a.device_token = "XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX"
    >> a.badge = 5
    >> a.sound = true
    >> a.alert = "foobar"
    >> a.send_notification
    => nil

Copyright (c) 2009 Fabien Penso. Released under the MIT license. Modified by [Sam Soffes](http://samsoff.es).
