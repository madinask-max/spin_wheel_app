This is a small project which I have implemented for one of my customer.
in which I have added few options like offers.
For each run, user will get an offer.
To run the APP : flutter run -d 10BF672C2P0098X
WITH WIRELESS: flutter run -d 192.168.1.8:5555
shaikmadinabasha@shaiks-MacBook-Pro spin_wheel_app % flutter run -d 192.168.1.8:5555
shaikmadinabasha@shaiks-MacBook-Pro spin_wheel_app % flutter logs
To make realse app : flutter build apk --release
WIRELESS CONNECTION

shaikmadinabasha@shaiks-MacBook-Pro spin_wheel_app % adb connect 192.168.1.8:5555
failed to authenticate to 192.168.1.8:5555

shaikmadinabasha@shaiks-MacBook-Pro spin_wheel_app % adb devices
List of devices attached
192.168.1.8:5555        device
shaikmadinabasha@shaiks-MacBook-Pro spin_wheel_app % flutter logs
