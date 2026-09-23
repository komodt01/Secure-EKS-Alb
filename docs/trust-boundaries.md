# EKS Trust Boundaries

## Why the Boundaries Matter

An Amazon EKS environment crosses several security domains before a workload can interact with either Kubernetes or AWS services.

The cluster itself is therefore not a single security boundary.

This project demonstrates selected infrastructure and identity boundaries around the EKS environment. Other Kubernetes and application controls would need to be added for a production platform.

## The AWS-Facing Path

An application exposed through AWS load-balancing infrastructure would cross from an external or public-facing network context toward workloads operating inside the Kubernetes environment.

Conceptually:

**External Client → AWS Load Balancing → Kubernetes Service / Ingress → Application Workload**

This repository establishes part of the infrastructure needed to support that path:

* Public subnets are available for internet-facing AWS resources.
* Private subnets contain the EKS managed worker nodes.
* The AWS Load Balancer Controller has a dedicated AWS identity through IRSA.
* Public and private subnet tags support Kubernetes load-balancer discovery.

The repository does **not** implement the complete application path.

Kubernetes Ingress resources, application Services, application Pods, TLS configuration, DNS, WAF configuration, and application-specific security controls are outside the implemented scope.

Those controls should not be inferred simply because the AWS Load Balancer Controller integration is supported.

## The Kubernetes Management Path

The management path has a different trust model from the application traffic path.

For this project:

**Administrator / kubectl → Public EKS API Endpoint → EKS Control Plane → Kubernetes Resources**

The EKS API endpoint is configured for public access.

That does not mean the worker nodes are public. The managed node group is explicitly deployed into the private subnet tier.

These are separate architecture decisions:

* **API exposure** determines how the Kubernetes control plane can be reached.
* **Node placement** determines where Kubernetes compute operates.

A production architecture would need to make additional decisions about control-plane access, such as source-network restrictions, private endpoint access, administrative identity, Kubernetes RBAC, privileged administration, and monitoring of administrative activity.

Those controls are not demonstrated by the current Terraform configuration.

## The Workload-to-AWS Identity Path

The strongest identity boundary demonstrated by this project is the relationship between Kubernetes workload identity and AWS IAM.

The path is:

**Kubernetes Service Account → EKS OIDC Provider → AWS STS → IAM Role → AWS APIs**

The AWS Load Balancer Controller is associated with the Kubernetes service account:

`system:serviceaccount:kube-system:aws-load-balancer-controller`

The IAM trust policy requires both:

* The expected Kubernetes service-account subject.
* The `sts.amazonaws.com` audience.

This limits role assumption to the intended federated workload identity rather than using the worker-node IAM role as the controller's AWS identity.

The architectural principle is important beyond this specific controller:

> AWS permissions required by a Kubernetes workload should be associated with the workload identity rather than inherited unnecessarily from the underlying node.

The IAM policy attached to the controller role determines what AWS operations that identity can perform. IRSA establishes **who may assume the role**; the IAM permissions determine **what the assumed role may do**.

These are related but separate enforcement points.

## Public and Private Network Placement

The VPC spans two Availability Zones and separates public and private subnet tiers.

The EKS managed node group operates in the private subnets.

The public subnets provide a separate network tier for AWS resources that require internet-facing placement.

Private placement reduces direct network exposure of the worker nodes, but it should not be interpreted as complete Kubernetes network isolation.

The current project does not demonstrate:

* Kubernetes NetworkPolicy.
* Pod-to-pod segmentation.
* Namespace isolation.
* Service-mesh policy.
* Application security groups.
* Ingress or egress policy at the workload level.

Those would represent additional enforcement boundaries in a production Kubernetes environment.

## Where Control Changes Hands

The architecture contains several points where one security system hands control to another.

| Transition                          | Security Decision                                               |
| ----------------------------------- | --------------------------------------------------------------- |
| Administrator → EKS API             | Who may reach and authenticate to the Kubernetes control plane? |
| EKS → Worker Nodes                  | Where does Kubernetes compute operate?                          |
| Kubernetes Service Account → OIDC   | Which workload identity is making the AWS request?              |
| OIDC → STS                          | May that federated identity assume the IAM role?                |
| IAM Role → AWS API                  | What AWS operations may the controller perform?                 |
| Public Tier → Private Workload Tier | Which traffic is allowed to reach Kubernetes workloads?         |

The project directly demonstrates only selected portions of these decisions.

In particular, it implements the network placement and IRSA foundation but does not claim to implement a complete production traffic-control or Kubernetes authorization model.

## Failure and Bypass Considerations

The security value of these boundaries depends on preventing alternate paths around them.

Examples that matter in a production design include:

**Overprivileged node identity**

If workloads can obtain broad AWS permissions from the worker-node role, workload-specific IRSA controls can be undermined.

**Overprivileged controller role**

Restricting which service account can assume a role does not compensate for unnecessarily broad permissions attached to that role.

**Unrestricted Kubernetes administration**

Private worker nodes do not protect the environment if administrative access to the Kubernetes API is insufficiently controlled.

**Uncontrolled workload traffic**

Subnet separation alone does not determine which Pods or Services may communicate with each other.

**Credential or token misuse**

Federated workload identity reduces the need for long-lived AWS credentials, but the resulting tokens and assumed-role sessions still require appropriate lifecycle and monitoring controls.

## Production Boundaries Not Implemented Here

A production EKS platform would normally require additional architecture decisions around:

* Kubernetes RBAC and administrative roles.
* EKS API endpoint restrictions.
* Pod and namespace isolation.
* Kubernetes NetworkPolicy or equivalent workload segmentation.
* Secrets management.
* Container image provenance and vulnerability management.
* Admission controls and workload policy.
* Runtime security.
* Centralized audit and security logging.
* Detection and incident response.
* Ingress security.
* TLS and certificate lifecycle.
* DNS.
* WAF or other application-edge controls where required.
* Egress restrictions.
* Supply-chain controls for Helm charts, container images, and Kubernetes manifests.
* Environment separation between development, test, and production.
* Backup, recovery, and cluster resilience requirements.

These are production architecture considerations, not controls implemented by this repository.

## Architecture Takeaway

The useful security lesson from this project is not simply that the EKS worker nodes are private or that IRSA is enabled.

It is that different parts of the platform rely on different enforcement boundaries:

**Network placement controls where compute runs.**

**The Kubernetes API defines a separate administrative boundary.**

**OIDC establishes the federated workload identity.**

**STS evaluates whether that identity can cross into AWS IAM.**

**IAM determines what the resulting AWS identity can do.**

Keeping those decisions separate makes it easier to identify excessive privilege, unintended access paths, and missing controls as an EKS environment grows toward production.
