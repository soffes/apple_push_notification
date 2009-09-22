# Apple Push Notification

This plugin helps you use the Apple Push Notification system.

## Converting Your Certificate

Once you have the certificate from Apple for your application, export your key
and the apple certificate as p12 files. Here's how:

1. Click the disclosure arrow next to your certificate in Keychain Access and select the certificate and the key. 
2. Right click and choose `Export 2 items...`. 
3. Choose the p12 format from the drop down and name it `cert.p12`. 

Now covert the p12 file to a pem file:

    $ openssl pkcs12 -in cert.p12 -out apn_development.pem -nodes -clcerts

Put `apn_development.pem` in `config/certs` in your rails app. For production, name your certificate `apn_production.pem` and put it in the same directory. When your rails environment is production, the production Apple Push Notification server and production certificate will be used.

## Installing

Simply run the following commands to install apple-push-notification as a plugin to your rails app.

    $ script/plugin install git://github.com/samsoffes/apple_push_notification.git
    $ rake apn:migrate

## Example

    $ ./script/console
    >> a = ApplePushNotification.new
    >> a.device_token = "XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX"
    >> a.badge = 5
    >> a.sound = true
    >> a.alert = "Hello world"
    >> a.send_notification
    => nil

### Notes

* The spaces in `device_token` are optional. 
* The `sound` can be the filename (i.e. `explosion.aiff`) or `true` which will play the default notification sound.

Copyright (c) 2009 Fabien Penso. Released under the MIT license. Modified by [Sam Soffes](http://samsoff.es).
