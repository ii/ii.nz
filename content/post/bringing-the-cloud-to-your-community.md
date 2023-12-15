+++
title = "Bringing the cloud to your community"
author = ["Hippie Hacker"]
date = 2017-01-04
tags = ["kubernetes", "cloud"]
categories = ["guides"]
draft = false
summary = "Creating local clouds should not be hard"
+++

# creating local clouds should not be hard

It should be easy to deploy complex cloud infrastructure onto _real hardware_
without having to be an IT guru. We want to use a $9 C.H.I.P flashed from the
web with a paperclip to setup the same open source cloud infrastructure used by
Google.

Several years ago we demoed a Banana Pi powering on and installing different
cloud operating systems to real hardware.

The advent of [Docker](https://www.docker.com/) and IoT provisioning platforms
that utilize containers like [Resin](http://resin.io/) are democratizing access
to deploy and manage complex infrastructure.

# Resin and IoT hardware can create and manage your local cloud

It just takes a few steps:

*   flash a [C.H.I.P.](https://getchip.com/pages/chip) (or Raspberry Pi) with
    Resin OS via the web
*   connect the Resin device to some computers set to [netboot
    PXE](https://en.wikipedia.org/wiki/Preboot_Execution_Environment)
*   watch your Resin console as your computers are turned into a cloud
    (Kubernetes running GitLab or OpenStack)

## Flash a CHIP (or Raspi) with Resin OS

We have recently pulled together a [Docker
build](https://gitlab.ii.org.nz/iichip/Hanlon/blob/resin/Dockerfile)
that we push to our resin project.

<figure class="oversized">
<img src="/images/2017/01/ii_k8s_resin.png" />
<figcaption>
</figcaption>
</figure>

## Connect the Resin device to some computers configured to netboot

Once the Resin + ii device is connected to our network we power on the servers.
This could be done manually, but what fun would that be?

<figure class="oversized">
<img src="/images/2017/01/ii_poweron.png" />
<figcaption>
</figcaption>
</figure>

We use some software that listens to the network boot requests and orchestrates
the installation of the OS installs called
[Hanlon](https://github.com/csc/Hanlon).

When the servers power up they register with the Hanlon. This process is [fairly
complex](https://github.com/csc/Hanlon/wiki/How-is-it-all-connected#breakdown)
but allows us to [save information about the server
hardware](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/node_setup.rb)
and the servers wait to be told what to do next via the [Hanlon
API](https://github.com/csc/Hanlon/wiki/Hanlon-API-Overview).

<figure class="oversized">
<img src="/images/2017/01/ii_register.png" />
<figcaption>
</figcaption>
</figure>

## Watch your Resin console as your computers are turned into a cloud

Once we have enough nodes, we use Hanlon info about the hardware (number of
cores for now) to [select the right
hardware](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/node_state.rb)
for the Kubernetes master (the one with the least cores) and allocate the rest
as minions.

<figure class="oversized">
<img src="/images/2017/01/ii_k8s_waiting.png" />
<figcaption>
</figcaption>
</figure>

This allows us to generate a local ssl Certificate Authority and [create signed
certificates](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/certs.rb)
for all our nodes.

<figure class="oversized">
<img src="/images/2017/01/ii_certs.png" />
<figcaption>
</figcaption>
</figure>

Now we tie it all together with [Hanlon tags, models, and policies per
node](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/hanlon.rb)
that deploy CoreOS.

<figure>
<img src="/images/2017/01/ii_provision_hanlon.png" />
<figcaption>
</figcaption>
</figure>

We wait for all the [CoreOS nodes to be provisioned and
available](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/hanlon.rb#L51),
logging the state changes along the way.

<figure class="oversized">
<img src="/images/2017/01/ii_os_complete.png" />
<figcaption>
</figcaption>
</figure>

Next we use chef-provisioning-ssh to [ensure each CoreOS node is
ready](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/via_ssh.rb#L10).

<figure class="oversized">
<img src="/images/2017/01/ii_k8s_ready.png" />
<figcaption>
</figcaption>
</figure>

Then the master [needs to be
initialized](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/via_ssh.rb#L46).

<figure>
<img src="/images/2017/01/ii_k8s_configure_master.png" />
<figcaption>
</figcaption>
</figure>

And then [the
minions](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/via_ssh.rb#L83).

<figure class="oversized">
<img src="/images/2017/01/ii_k8s_minions.png" />
<figcaption>
</figcaption>
</figure>

We [setup
kubectl](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/kubectl.rb)
to communicate to our new Kubernetes cluster.

<figure class="oversized">
<img src="/images/2017/01/ii_k8s_kubectl.png" />
<figcaption>
</figcaption>
</figure>

[Create Kubernetes
manifest](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/blob/master/provision/recipes/main.rb#L20)
specific to our [deploy of
gitlab](https://gitlab.ii.org.nz/iichip/chef-provisioning-k8s/tree/master/provision/files).


<figure class="oversized">
<img src="/images/2017/01/ii_k8s_gitlab.png" />
<figcaption>
</figcaption>
</figure>

The end result is a gitlab instance running on kubernetes!

<figure class="oversized">
<img src="/images/2017/01/ii_k8s_pods.png" />
<figcaption>
</figcaption>
</figure>

We can looking up our service ip, which we can add to DNS.

<figure class="oversized">
<img src="/images/2017/01/ii_k8s_ingress.png" />
<figcaption>
</figcaption>
</figure>

## Start developing in your community on a local cloud

Yes... that's gitlab, deployed from any resin device, to real hardware running kubernetes.

<figure class="oversized">
<img src="/images/2017/01/ii_gitlab_running.png" />
<figcaption>
</figcaption>
</figure>

# Why is this important?

GitLab published a blog post detailing how quickly you can take your ideas to production using a local cloud

*   [In 13 minutes from Kubernetes to a complete application development
    tool](https://about.gitlab.com/2016/11/14/idea-to-production/)

**There are so many places to go from here. We are looking for funding and
people who share our passion for creating instant infrastructure that is easy
for others to use, change, and replicate.** Send [us an
email](mailto://ii.org.nz/) or give us a ring at +64 22 646 1502.


