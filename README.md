# Facial Analysis Dating App (iOS)

![App screenshots](https://i.imgur.com/MErAENq.png)

## Introduction

This project is a dating app for iOS that allows users to connect with others and find potential matches based on their facial similarity. It includes features such as user authentication, profile customization, recommendations, chat functionality, settings, face detection, face similarity grading and more. The app is built using Swift and SwiftUI, it leverages Firebase for authentication, cloud storage, and cloud Firestore for data management. The app connects to a local server implemented in Python using FastAPI in order to make use of the [DeepFace library](https://github.com/serengil/deepface).

## What I Learned

- This project was my introduction to Swift and SwiftUI, and I had to learn almost everything from scratch, which helped me gain a solid understanding of the language.
- I gained valuable experience using Firebase, including its services such as Authentication, Firestore, and Cloud Storage, which expanded my knowledge of backend development.
- This project also gave me the opportunity to develop a REST service using FastAPI, which enhanced my understanding of Python and backend development.
- I learned how to utilize the DeepFace library for facial feature analysis, which added a new skill to my toolkit.
- Implementing the MVVM (Model-View-ViewModel) design pattern in this project allowed me to enhance my understanding of architectural patterns and their application in mobile app development.

## App Features

The dating app comes with a range of features to provide users with a seamless and enjoyable experience. Some of the key features include:

- User authentication with email and password using Firebase authentication, allowing users to create an account, sign in, and recover their password.
- Profile customization, allowing authenticated users to personalize their profile with necessary information such as name, age, photos, and other details. Profile data is stored in Cloud Firestore for easy retrieval and management.
- Face photo validation, where user's face photo is sent to a local server to be checked for validity using Deepface, ensuring that only valid face photos are accepted.
![User authentication screenshots](https://i.imgur.com/34iSL1C.png)

- Access to a list of recommended users based on certain filters, such as facial similarity, location, interests, and other preferences. Users within a certain radius are fetched from Cloud Firestore and sent to a local server for analysis using Deepface to determine similarity scores.
![Reccommendations screenshots](https://i.imgur.com/z0bAo81.png)

- Chat functionality, allowing authenticated users to open a profile and view more details about another user, send "likes," and initiate chats. Chat data is stored in Cloud Firestore for easy retrieval and synchronization.
- Recent chats list, allowing users to view and access their recent chats, where they can send and receive messages in real-time.
![Chat service screenshots](https://i.imgur.com/vSVXuK3.png)

- User profile editing, enabling authenticated users to modify their email address and password using Firebase authentication.
- Account deletion, allowing users to delete their account and associated data for convenience.
- Logout functionality, allowing users to log out of their account.
![User account settings screenshots](https://i.imgur.com/vL5hef5.png)

- Dark mode support, providing users with the option to switch to a dark color scheme for a visually appealing and comfortable experience.
![Dark mode screenshots](https://i.imgur.com/GPuXc20.png)

- iPadOS support, , adapting to the larger screen size for a seamless experience on iPad.

## Future Development

This dating app is just the beginning, and there are plans for further development in the future. Some potential features that could be added in the future include:

- Implementing additional filters for recommendation, such as interests, hobbies, and compatibility scores.
- Integrating real-time notifications for chat messages using Firebase Cloud Messaging.
- Implementing location-based features, such as showing nearby users on a map.
- Enhancing security measures, such as implementing additional authentication methods like two-factor authentication.
- Implementing a reporting system for inappropriate content or behavior.
- Adding additional languages and localization support for a global user base.
- Enhancing the user interface and user experience.
