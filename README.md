# Musitech: AI-Enhanced Music Appreciation App

The project aims to utilize AI media generation as a way to help make music appreciation more accessible for individuals who might struggle to engage closely with classical music. In designing this project, I wanted to explore how AI generated tools can be used as a supplement to help enhance a listener’s classical music experience. In order to do so, I chose to create a mobile application that automatically generates text information such as a musical piece’s historical background, a description about its musical qualities, or what you might expect to hear when listening to the piece. The application is designed in SwiftUI for iOS devices and requires the device’s microphone to input an audio recording of whatever the user is listening to in real time. This audio input is fed to Apple Developer’s ShazamKit in order to identify the piece of music. Upon identification, the piece’s title and artist name are then sent in manually designed question format to OpenAI’s ChatGPT text model to generate the text information listed above. The end result is a mobile application that allows the user to conveniently contextualize a piece of music in real listening time.

Dependencies include OpenAISWift, ShazamKit, and SnapToScroll. In order to call OpenAISwift API, an authentication token must be on line 91 of ContentView.swift at 
>  client = OpenAISwift(authToken: "<YOUR TOKEN HERE>")

Video Demonstration: https://youtu.be/qnwRhoXWjKA 

Final Report: https://docs.google.com/document/d/1fP22cXtaTcwnhocsETDZOGkQTyCI6UgjpeqyoeLVnco/edit?usp=sharing 