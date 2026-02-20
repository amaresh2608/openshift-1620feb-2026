# Day 5

## Info - Openshift Network Policy
<pre>
- is essentially Kubernetes NetworkPolicy with some OpenShift-specific integrations
- is the primary mechanism for controlling network traffic between pods (and to/from external endpoints) 
  at L3/L4 level (IP addresses, ports, protocols)
- by default, pods in a namespace can talk freely to each other and to the outside world unless some Network Policy prevents it
- When we create a Network Policy for a particular Project(Namespace), all Pods in that Project(Namespace) 
  are isolated from the ingress(incoming) traffic 
- Only traffic that are allowed by explicit Network policiy are permitted 
- Multiple Policies in the same namespace(project) are combined(ORed together) 
</pre>
