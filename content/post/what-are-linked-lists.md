---
title: "What are Linked Lists"
date: 2015-09-07
draft: false
tags: ["tutorials", "beginner"]
author: Evan Smith
image: defimg/linkedlists.png
---

# What is a linked list?
A linked list is a *linear* data structure where each element is a separate object. Each element is called a **node** and has two main items: its data and a tail \(i.e. a reference to the next node\). So a list will go from tail to tail until, eventually, we reach a null value and know we’ve reached the end.

A linked list is a dynamic data structure. The number of nodes in a list is not fixed and can grow and shrink on demand. Any application which has to deal with an unknown number of objects will need to use a linked list.

One disadvantage of a linked list against an array is that it does not allow direct access to the individual elements. If you want to access a particular item then you have to start at the head and follow the references until you get to that item.

![dev-env image](/post-images/linked-lists/linkedlists.webp)

# Types Of Linked List

There are mainly \(although not only\) two different types of linked list

* **Singly Linked List**: The linked list as described in the above section
* **Doubly Linked List**: Essentially the same except we now have three items in each node: data, a tail and a head

In a doubly-linked list, the head points to the previous node and the tail points to the next node. With this, we can traverse the list in both directions.