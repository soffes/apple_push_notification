# Apple Push Notification

This plugin helps you use the Apple Push Notification system.

## Installing

Install as a gem:

    # Add to config/environment.rb:
    config.gem "apple_push_notification", :source => "http://gemcutter.org/"

    # At command prompt:
    $ sudo rake gems:install

or as a plugin:

    $ script/plugin install git://github.com/samsoffes/apple_push_notification.git

Once you have installed apple\_push\_notification, run the following command:

    $ rake apn:migrate

## Converting Your Certificate

Once you have the certificate from Apple for your application, export your key
and the apple certificate as p12 files. Here's how:

1. Click the disclosure arrow next to your certificate in Keychain Access and select the certificate and the key. 
2. Right click and choose `Export 2 items...`. 
3. Choose the p12 format from the drop down and name it `cert.p12`. 

Now covert the p12 file to a pem file:

    $ openssl pkcs12 -in cert.p12 -out apn_development.pem -nodes -clcerts && rm -f cert.p12

Put `apn_development.pem` in `config/certs` in your rails app. For production, name your certificate `apn_production.pem` and put it in the same directory. See the environment section for more about environments.

## Environment

By default, the development environment will always be used. This makes it easy to test your app in production before your iPhone application is approved and your production certificate is active. You can easily override this by adding this line in an initializer or environment file.

    ApplePushNotification.enviroment = Rails.env.to_sym

You can also simply set `ApplePushNotification.enviroment` to `:development` or `:production`. Setting the `ApplePushNotification.enviroment` chooses the appropriate certificate in your `certs` folder and Apple push notification server.

## Example

You can easily send a test notification from the console once you have your certificate configured.

    $ script/console
    >> a = ApplePushNotification.new
    >> a.device_token = "XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX"
    >> a.badge = 5
    >> a.sound = true
    >> a.alert = "Hello world"
    >> a.send_notification
    => nil

### Notes

* The spaces in `device_token` are optional and will be ignored. 
* The `sound` can be the filename (i.e. `explosion.aiff`) or `true` which will play the default notification sound.

Copyright (c) 2009 [Sam Soffes](http://samsoff.es). Released under the MIT license. Forked from Fabien Penso.
