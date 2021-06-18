# iCloud Document Storage

iCloud Drive is Apple's essential connection between all your devices, Mac, iPhone, iPad, even your Windows PC.While the cost of storage seems expensive in comparison to other online storage services, its advantage is that it works natively across all your devices.

![alt text](https://cdn-images-1.medium.com/max/800/1*iZHl-IXaow5Ts7VOwCaS8Q.png)

In this iCloud tutorial, you'll learn how to create folder and add files in iCloud from your app as well as how to move and copy files from Local to iCloud and Vice versa.

You can download source code at end of this blog.

Let's see how to do it 🙂

# Setting up iCloud Storage APIs
Let's start by creating a new project for iOS. 

You can select the single view application template.
In this tutorial we're not going to touch the UIDocument class at all. 🤷‍♂️

![alt text](https://cdn-images-1.medium.com/max/1200/1*hPpJ-D94n5ZdWJis_ZBYyw.png)

The first step is to enable iCloud capabilities, which will generate a new entitlements file in your project. Also you'll have to enable the iCloud application service for the app id on the Apple developer portal. You should also assign the iCloud container that's going to be used to store data. you have to do this manually.
 
#### Note: You need a valid Apple Developer Program membership in order to set advanced app capabilities like iCloud support. So you have to pay $99/year🤑

The next step is to modify the Info.plist. I would recommend selecting "Open As" option and use "Source Code" so you can work with pretty standard XML.

![alt text](https://cdn-images-1.medium.com/max/800/1*bKw8cJgeg_8pmBndhv-ULg.png) 

[Read more....](https://medium.com/@parth.gohel/icloud-document-storage-d338cf745076)
