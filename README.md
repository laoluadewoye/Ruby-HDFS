# Ruby-HDFS
A small recreation of Hadoop Distributed File System using Ruby, gRPC, and 
Kubernetes. This project uses an MIT license, which is in the root project 
directory.

## Table of Contents

- [Introduction](#introduction)
- [Kubernetes Concepts](#kubernetes-concepts)
  - [Kubernetes Pods](#kubernetes-pods)
  - [Kubernetes States](#kubernetes-states)
  - [Kubernetes Deployments and StatefulSpecs](#kubernetes-deployments-and-statefulspecs)
  - [Kubernetes Services](#kubernetes-services)
- [The Planned Architecture](#the-planned-architecture)
  - [RPC Setup](#rpc-setup)
	- [Interface RPC](#interface-rpc)
	- [Namenode RPC](#namenode-rpc)
	- [Datanode RPC](#datanode-rpc)
  - [Spec Generation for Kubernetes API](#spec-generation-for-kubernetes-api)
- [Resources](#resources)

# Things needed to run this project
- Ruby 3.2.2 or later. I would install it using Railsinstaller because getting 
  Ruby on Rails working is a pain in the butt, especially with sqlite3.
- gRPC tools like protoc.
- Cloudflare SSL, or cfssl for working with TLS certificates.
- Whatever is in the Gemfile. Install using `bundle install`.
- A Kubernetes cluster, such as Amazon EKS, or a local Kubernetes cluster 
  such as Minikube or Kind.

# Introduction

The lore behind this is pretty simple. I had just come out of spring classes, 
and had alot of big data analytics stuff crammed into my head. In addition, I
had learned of some other things as well, and it would be easier to list them
as bullet points rather than in paragraph form.

- Apache Hadoop, Map-Reduce, YARN, etc.
- Remote Procedure Calls and gRPC
- Kubernetes and StatefulSet deployments
- Tightly restricting document length to 80 columns for compatibility with more
  basic systems. Common in really basic shell utilities.
- Ruby and Ruby on Rails
- Amazon Web Services, specifically Elastic Kubernetes Service (EKS)
- Zero Trust Architecture

It was like making the Powerpuff Girls. I just needed that chemical X to make
the whole concoction explode, and that ended up being a desire to do literally
anything once my spring semester ended.

Out of that explosion birthed this project to create a small but working
simulation of Apache Hadoop Distributed File System, or HDFS. My recreation of
HDFS is going to be based in Kubernetes using a microservices-like architecture
that will rely on gRPC for standardized communication. Hopefully, if I can get
a proper RoR website working, I can even create an cloud solution that can be
dynamically spun up for anyone who doesn't wish to install anything.

This project is going to help me learn all of the above a bit more, but the
important thing is that it is also fun. I'm not going to take it as seriously
as PKI-Practice-Python, but I'll do minimal stuff like version control, image
tagging, the usual stuff. I'll also try to create a kubernetes solution and a
local simulation in tandem so that you wouldn't _need_ kubernetes to run it.

# Kubernetes Concepts 

Kubernetes (as of May 2025) has StatefulSet deployments which I ultimately
want to use to make this work. But lets start small.

## Kubernetes Pods

A Kubernetes atomic app unit is called a Pod. A pod consists of one or more
containers, however many is needed to run the desired app. It is possible to
tell Kubernetes to simply create a Pod, but what Kubernetes is really good for
is orchestrating desired states.

## Kubernetes States

In this context, a Kubernetes state is the desired configuration and activity
that you want Kubernetes to maintain for a foreseeable amount of time. This
kind of definition is mostly associated with the concept of Availability, where
you would want to achieve 100% uptime for any service you are running, 24/7,
365 days a year. The Kubernetes API decouples-

1) The act of declaring what state you want Kubernetes to create, approach, and
   maintain.
2) The act of carrying out functions to approach and maintain the desired
   state.

This distinction can be made clearer with an example. Pretend you creating a
software solution to regulate traffic in a given four-way intersection. In this
case, the high-level goal is to regulate traffic. If we were to break that 
down, we could say that "regulating traffic" means ensuring that cars aren't 
sitting at red lights for too long. "Too long" implies the movement of time, 
so we can measure the time the car sits at a red light to create a metric. 
Ultimately, we would want this time to be as low as possible.

However, we are handling multiple cars coming from four different directions. 
There are cases when one direction has light traffic while another has heavy 
traffic. There are cases where one direction can be given a green light, but 
the time the green light is on is not enough time for **all** cars to move 
through the intersection, and some cars are left over. Of course to track all 
cars is impossible, but we can set a limit to how many cars per lane, per 
direction we want to track, and ensure that we can limit the time that those 
specific cars are sitting at the intersection.

In fact, if we are going to only track how long the cars **sit** at the 
intersection, we can forgo the lights entirely in regards to tracking and 
focus on minimizing the time that specific cars occupy specific spots in any
given lane from any given direction in the intersection. The lights can simply 
be a tool we used to achieve our new goal.

What we have just done is go from-

"I want to use this software solution to regulate traffic at this 
intersection."

to-

"I want to minimize the amount of time that cars are sitting in specific 
lanes at this intersection."

Both statements seek to achieve the same goal, but the differences between 
them should not be understated. The second one is more focused on controling 
a specific aspect of the intersection, has a clear scope on what will be 
monitored, and can be cleanly converted into form quantiative form for 
analysis. 

In other words, we have declared **what state we want to first create, then 
approach, and maintain.** In the process, we also relegated traffic 
lights to a tool we can use to **carry out functions to approach and 
maintain the desired state.**

The importance of this is probably still implied, but if you're going to have 
an **orchestrative** solution such as a traffic light system, it is alot more 
dynamic to create a system that uses real-time car sitting data to adjust the 
times of traffic light states rather than to approach the problem from the 
original goal, where you are more likely to create something static and 
formulaic. This is not to say that the latter is bad, as such formulaic 
systems have the backing of robust studies to predict the flow of something 
like traffic.

This **is** to say that for cases where you would need to maintain high 
availability in an unpredictable enviornment where anything can happen, such 
as maintaining a stable condition in a cloud computing cluster, you need a 
solution that knows how to adapt on the fly, not one that can follow a script. 
And to achieve that solution starts with how the problem is approached. 

Kubernetes solves this problem by decoupling desired state from functions, 
creating a reactive system where you can simply say what Pods you wish to run, 
how you want them to interact with each other and the outside world, and what 
other parameters you want in place. You would do this through the kuberenetes 
API, as the backend server handles the underlying functionality. 

Once you submit your desired state to the API, the Kubernetes back-end server 
run whatever functions are necessary to create, approach, and maintain that 
desired state.

I know I probably repeated alot, but I hope now that all the words mean 
more than before.

## Kubernetes Deployments and StatefulSpecs

This brings us back to Pods. You can ask Kubernetes to spin up a Pod for you, 
but it's not going to track it or anything. A better strategy is to send a 
Deployment through the API that species what Pods you want, how many do you 
want, and other details as necessary. A deployment implies the need for it to
exist for an unspecified amount of time, so Kubernetes would add more tracking 
functionality to ensure that Pods are running cleanly.

Kubernetes' API offers multiple ways to specify a Deployment. There is, of 
course the basic Deployment spec, which you can read up on in your own time. 
But there is also specifically creating a ReplicaSet spec which creates then 
manages multiple copies of the Pod you want. 

There is also the StatefulSet spec, the one I wish to use. Deployments and
ReplicaSets do not care for the specific nature of a given Pod, only that 
a Pod is made. In StatefulSets, Pods are given specific identifiers because
the order that they are created in matters. This information is slotted into 
places such as the name of a container in the pod, which is data I can utilize 
in my Ruby program to identify specific characteristics. This is crucial for 
distributed storage because often, there is a primary node to go to for things 
and coordinating who is that node is helpful.

## Kubernetes Services

Lastly, I want to leverage Kubernetes services to control how one StatefulSet 
interacts with another StatefulSet. Kube-services enable the ability to access 
information through an understandable API, similar to gRPC. Enough said, it 
will make my life easier.

# The Planned Architecture

With all that said, the network architecuture for this project will have three 
main layers.

1) The interface layer will contain the pod used by the user to interact with 
   the distributed file system.
2) The name layer will contain pods operating as the Name Nodes of the 
   distributed file system.
3) The data layer will contain pods operating as the Data Nodes of the 
   distributed file system.

For communication, gRPC protocol buffers will be implemented so that every 
node can know how to communicate with another. Buffers will be designed 
from a server perspective, meaning a server will only have an rpc service if 
it is for a need that only that server can provide. You will see what I mean 
in the following subsections.

Somewhere in the gRPC system, there will be authentication for Zero-Trust 
compliance.

All inter-layer communication will happen through the use of headless 
services. When combining a headless service with a statefulset, Kubernetes 
automatically creates a cluster-local DNS-resolvable address for every pod. 
This is all that's needed for coordinating the HDFS cluster interally, and a 
Ingress object can be created to route communication between the user and the 
interface layer.

As for the storage architecture, it would be persistent volume claims for each 
Pod, plus a shared file system as a backup. That way, I can have my cake and 
eat it too. Plus, it gives me one location to see how everything's developing.

At a high level, that is about it. The only other thing is that I will be 
keeping the CRUD (Create, Retrieve, Update, Delete) paradigm in the back of my 
head for this project.

## RPC Setup

This section will clarify what calls each layer would handle from a server 
perspective. Session tokens, encrypted content, and other add ons can be added 
to make the intercommunication more secure.

### Interface RPC

The interface layer is where the user will send commands for CRUD mechanics of 
the files, the files' data, and the files' metadata. Below is a list of things 
that surrounding entities should only send to a given interface pod.

- Namenode Keep-alive messages. There's no point in running an HDFS service if 
  no one is there to use it. The primary and secondary name node pods will be 
  able to ping the interface pod to make sure that it's reachable and that the 
  user still wants to use it. If there is no response or the response is to 
  shut down, then that is what will happen. This message can carry with it 
  "busy" metrics so that the interface pod will always know who to ask.
- User registration messages. Unique accounts will be used to control what 
  person sees what. This will also allow for dynamic views, dynamic kubernetes 
  objects, etc.
- User status messages. Actions that the user does can be sent to the 
  interface as proof of activity. If some time goes on without any activity, 
  it is assumed there is no longer a user and the entire system should shut 
  down, but maintain state unless otherwise specified to reset on turn off.

### Namenode RPC

The name layer is where the the name nodes will coordinate between the 
interface layer, the data layer, and amongs themselves. Below is a list of 
things that surrounding entities should only send to a given namenode pod.

- Namenode Keep-alive messages. Name nodes should send periodic keep-alive 
  messages to the other name nodes. If name nodes do not recieve keep-alive 
  messages in an expected timeframe, then they should take action to fix the 
  problem. These messages should contain statuses for added monitoring.
- Datanode Keep-alive messages. Data nodes should send periodic keep-alive 
  messages to the other name nodes. If name nodes do not recieve keep-alive 
  messages in an expected timeframe, then they should take action to fix the 
  problem. These messages should contain statuses for added monitoring.
- Interface Create File messages. An interface node can send a request to add 
  a file to the HDFS.
- Interface Retrieve File messages. An interface node can send a request to 
  obtain a file from the HDFS.
- Interface Update File messages. An interface node can send a request to 
  update a file from the HDFS. This could be anything from contents to 
  metadata.
- Interface Delete File messages. An interface node can send a request to 
  delete a file from the HDFS.
- Datanode Block Update messages. Any block modification that is not a 
  response to something the namenode initiated should be sent to a namenode.

### Datanode RPC

The data layer is where the data pods will communicate with name layer upon 
requests for CRUD file interactions and status updates. Below is a list of 
things that the name layer pods should only send to a given datanode pod.

- Namenode Create Block messages. A namenode can send a request to add a block 
  to a datanode's local storage.
- Namenode Retrieve Block messages. A namenode can send a request to obtain a 
  block from a datanode's local storage.
- Namenode Update Block messages. A namenode can send a request to update a 
  block in a datanode's local storage.
- Namenode Delete Block messages. A namenode can send a request to delete a 
  block in a datanode's local storage.
- Namenode Status messages. A namenode can periodically request the status of 
  a given datanode while sending their own information as well. This can 
  enabled datanodes to choose where to send stuff they initiate.

## Spec Generation for Kubernetes API

Secrets

IPv4 Addresses

Configurations

GRPC information

Limits on Storage capacity

Logs

# Resources

https://medium.com/@aelgees/getting-started-with-ruby-grpc-a-comprehensive-guide-with-project-example-41dd940bcd1d 

https://protobuf.dev/programming-guides/proto3/ 

https://protobuf.dev/installation/ 

https://grpc.io/docs/guides/auth/

https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/

https://www.youtube.com/watch?v=DvXkD0f-lhY

https://github.com/codequest-eu/grpc-demo/tree/master
