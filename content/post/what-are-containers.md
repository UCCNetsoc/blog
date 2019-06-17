---
title: "What are containers?"
date: 2015-08-07
draft: false
tags: ["tutorials"]
author: Evan Smith
image: defimg/whatarecontainers.png
---

Linux-based container infrastructure is an emerging cloud technology based on fast and lightweight process virtualization. It provides its users an environment as close as possible to a standard Linux distribution. As opposed to para-virtualization solutions \(Xen\) and hardware virtualization solutions \(KVM\), which provide virtual machines \(VMs\), containers do not create other instances of the operating system kernel. Due to the fact that containers are more lightweight than VMs, you can achieve higher densities with containers than with VMs on the same host \(practically speaking, you can deploy more instances of containers than of VMs on the same host\).

Another advantage of containers over VMs is that starting and shutting down a container is much faster than starting and shutting down a VM. All containers under a host are running under the same kernel, as opposed to virtualization solutions like Xen or KVM where each VM runs its own kernel. Sometimes the constraint of running under the same kernel in all containers under a given host can be considered a drawback. Moreover, you cannot run BSD, Solaris, OS/x or Windows in a Linux-based container, and sometimes this fact also can be considered a drawback.

The idea of process-level virtualization in itself is not new, and it already was implemented by Solaris Zones as well as BSD jails quite a few years ago. Other open-source projects implementing process-level virtualization have existed for several years. However, they required custom kernels, which was often a major setback. Full and stable support for Linux-based containers on mainstream kernels by the LXC project is relatively recent, as you will see in this article. This makes containers more attractive for the cloud infrastructure. More and more hosting and cloud services companies are adopting Linux-based container solutions. In this article, I describe some open-source Linux-based container projects and the kernel features they use, and show some usage examples. I also describe the Docker tool for creating LXC containers.

The underlying infrastructure of modern Linux-based containers consists mainly of two kernel features: namespaces and cgroups. There are six types of namespaces, which provide per-process isolation of the following operating system resources: filesystems \(MNT\), UTS, IPC, PID, network and user namespaces \(user namespaces allow mapping of UIDs and GIDs between a user namespace and the global namespace of the host\). By using network namespaces, for example, each process can have its own instance of the network stack \(network interfaces, sockets, routing tables and routing rules, netfilter rules and so on\).