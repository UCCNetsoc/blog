---
title: "What is MVC"
date: 2015-08-07
draft: false
tags: ["dev"]
author: Evan Smith
image: defimg/mvc.png
---

# What is MVC?

MVC is a software architecture – the structure of the system – that separates domain/application/business (whatever you prefer) logic from the rest of the user interface. It does this by separating the application into three parts: the model, the view, and the controller.

The model manages fundamental behaviors and data of the application. It can respond to requests for information, respond to instructions to change the state of its information, and even to notify observers in event-driven systems when information changes. This could be a database, or any number of data structures or storage systems. In short, it is the data and data-management of the application.

The view effectively provides the user interface element of the application. It’ll render data from the model into a form that is suitable for the user interface.

The controller receives user input and makes calls to model objects and the view to perform appropriate actions.

All in all, these three components work together to create the three basic components of MVC.

An Example
Imagine a photographer with his camera in a studio. A customer asks him to take a photo of a box.

The box is the model, the photographer is the controller and the camera is the view.

Because the box does not know about the camera or the photographer, it is completely independent. This separation allows the photographer to walk around the box and point the camera at any angle to get the shot/view that he wants.

Non-MVC architectures tend to be tightly integrated together. If the box, the controller and the camera were one-and-the-same-object then, we would have to pull apart and then re-build both the box and the camera each time we wanted to get a new view. Also, taking the photo would always be like trying to take a selfie – and that’s not always very easy.
