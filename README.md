# Ruby-HDFS
A small recreation of Hadoop Distributed File System using Ruby, gRPC, and 
Kubernetes.

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

With all that said, 