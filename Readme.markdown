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

Once you have installed ApplePushNotification, run the following command:

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

## Usage

You can use ApplePushNotification with an ActiveRecord model, standalone, or on any object.

### ActiveRecord

Just add `acts_as_pushable` to your model.

    class Device < ActiveRecord::Base
        acts_as_pushable
    end

You can then send a notification like this

    d.send_notification :alert => "I heart Rails"

The `send_notification` method accepts a hash of options for the notification parameters. See the Parameters section for more information.

Your model must have a `device_token` attribute. If you wish to change this to something else (like `device` for example), simply pass it like this `acts_as_pushable :device`.

### Standalone

Simply call `ApplePushNotification.send_notification` and pass the device token as the first parameter and the hash of notification options as the second (see the Parameters section for more information).

    $ script/console
    >> token = "XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX"
    >> ApplePushNotification.send_notification token, :alert => "Hello World!", :badge => 5, :sound => true
    => nil

### Any Object

You can extend ApplePushNotification with any class. It will look for the `device_token` method when sending the notification. When ApplePushNotification is extended, if `device_token=` isn't defined, getters and setters are generated.

    $ script/console
    >> token = "XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX"
    >> d = Object.new
    >> d.extend ApplePushNotification
    >> d.device_token = token
    >> d.send_notification :alert => "So flexible"
    => nil

See the Parameters section for more information on what `send_notification` accepts.

## Parameters

The following notification parameters can be defined in the options hash:

* `alert` - text displayed to the use
* `sound` - this can be the filename (i.e. `explosion.aiff`) or `true` which will play the default notification sound
* `badge` - this must be an integer

### Notes

* The spaces in `device_token` are optional and will be ignored. 

Copyright (c) 2009 [Sam Soffes](http://samsoff.es). Released under the MIT license. Forked from Fabien Penso.
