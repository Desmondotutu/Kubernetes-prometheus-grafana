---
How to monitor Kubernetes clusters with the Prometheus Operator
---

Kubernetes has become the preferred tool for DevOps engineers to deploy and manage containerized applications on one or multiple servers. These compute nodes are also known as clusters, and their performance is crucial to the success of an application. 
If a Kubernetes cluster isn’t performing optimally, the application’s availability and performance will suffer, leading to unhappy users and even revenue loss. Fortunately, several tools in the Kubernetes ecosystem can help you effectively monitor your Kubernetes cluster, including Prometheus.
In this guide, you’ll learn about the benefits of using Kubernetes operators. You’ll also learn how to deploy and use the Prometheus Operator to configure and manage Prometheus instances in your Kubernetes cluster. And finally, you’ll discover how to deploy Grafana in your Kubernetes cluster to help analyze and visualize the health of your Kubernetes clusters.

---
Why monitor Kubernetes clusters with Prometheus?
---
Prometheus is an open source tool that provides monitoring and alerting for cloud native environments. It collects metrics data from these environments and stores them as time series data, recording information with a timestamp in memory or local disk.
You can install and configure Prometheus on your Kubernetes cluster using a Kubernetes operator like Prometheus Operator.

---
What are Kubernetes operators?
---
Kubernetes operators are software extensions that extend the functionalities of the Kubernetes API in configuring and managing other Kubernetes applications. They make use of custom resources to manage these applications and their components.

---
Kubernetes controllers
---
In Kubernetes, there are control loops called Kubernetes controllers that monitor the state of the Kubernetes cluster to make sure it’s similar to or equal to the desired state. For instance, if you want to deploy a new containerized application, you create a deployment object in the cluster with the necessary details using the kubectl client or the Kubernetes dashboard. The Kubernetes controller receives information about this new object and then performs the required action to deploy your application to the cluster. Likewise, when you edit the object, the controller receives the update and performs the necessary action.

---
Kubernetes operators
---
Kubernetes operators use this Kubernetes controller pattern in a slightly different way. They’re application-specific, meaning different applications can have their own operators (which can be found on OperatorHub.io). The operators monitor the applications in the cluster and perform the required tasks to ensure the application functions in the desired state, which you configure in your custom resource definition (CRD).
Deploying Prometheus instances manually without using the Prometheus Operator or a Prometheus Helm chart can be hectic and time-consuming. You’d need to configure certain Kubernetes objects like ConfigMap, secrets, deployments, and services, which the Prometheus Operator abstracts on your behalf. The Prometheus Operator also helps you manage dynamic updates of resources, such as Prometheus rules with zero downtime, among other benefits.

---
Benefits of using Kubernetes operators
---
Operators provide multiple benefits to the Kubernetes ecosystem.
1. Packaging, deploying, and managing applications
Kubernetes operators provide smoother application deployment and management. For instance, cloud native applications with complex installation procedures and maintenance steps can be handled more easily, because you can create custom resources to automate and simplify complex installation procedures. Operators also improve the management of stateful applications like databases, so it’s easier to perform database backups and configure database applications. Using operators enables you to automate these and other complex processes.

2. Performing basic operations using kubectl
Since Kubernetes operators extend the functionality of the Kubernetes API server, they also allow you to use the kubectl client to run basic commands for custom resources such as GET and LIST, letting you manage your custom resources with commands you are already familiar with in the terminal.

3. Facilitating resource monitoring
Because Kubernetes operators perform custom tasks on an application based on the CRDs, they continuously monitor the application and cluster to check for anything that is out of place. If there is a misalignment in the application, like if the application isn’t in its expected state, the operators correct it automatically. This saves the Kubernetes administrator the trouble of identifying and correcting problems on the cluster.
How to deploy and configure the Prometheus Operator in Kubernetes
As noted earlier, Prometheus works well for monitoring your application and resources in your Kubernetes cluster. Below, we’ll show you how to use the Prometheus Operator to deploy and configure the Prometheus instance in your Kubernetes cluster.
Prerequisites

You need the following for this guide:
1.	A running Kubernetes cluster. You can use minikube, which supports Linux, Mac, and Windows, to set up a local cluster on your computer.
2.	A kubectl client installed on your computer.
Deploying the Prometheus Operator
You’re going to deploy Prometheus Operator in your cluster, then configure permission for the deployed operator to scrape targets in your cluster.
You can deploy by applying the bundle.yaml file from the Prometheus Operator GitHub repository: 
```bash
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
```
If you run into the error The CustomResourceDefinition "prometheuses.monitoring.coreos.com" is invalid: metadata.annotations: Too long: must have at most 262144 bytes, then run the following command:
```bash
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml --force-conflicts=true --server-side=true
```
This command allows you to deploy Prometheus Operator CRD without Kubernetes altering the deployment when it encounters any conflicts while installing the operator in your cluster. In this scenario your cluster complains of a long metadata annotation that is beyond the limit provided by Kubernetes. However, --force-conflicts=true allows the installation to continue without the warning stopping it. Additionally, --force-conflicts only works with --server-side. For more information on –server-side and --force-conflicts click here.
Once you’ve entered the command, you should get an output similar to this:
customresourcedefinition.apiextensions, deployment.apps/prometheus-operator created, serviceaccount/prometheus-operator created, …………………. And service/prometheus-operator created

When you run kubectl get deployments, you can see that the Prometheus Operator is deployed:
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
prometheus-operator   1/1     1            1           1m1s

Next, you’ll install role-based access control (RBAC) permissions to allow the Prometheus server to access the Kubernetes API to scrape targets and gain access to the Alertmanager cluster. To achieve this, you’ll deploy a ServiceAccount. Clone my github repository containing all the yaml files needed to setup Prometheus and Grafana

Link: https://github.com/Desmondotutu/Kubernetes-prometheus-grafana.git
Then, apply the file to your cluster:
```bash
kubectl apply -f prometheus_rbac.yaml
```
You should get the following response:
serviceaccount/prometheus created
clusterrole.rbac.authorization.k8s.io/prometheus created
clusterrolebinding.rbac.authorization.k8s.io/prometheus created
Deploying Prometheus
Now that you have deployed the Prometheus Operator into your cluster, you’re going to create a Prometheus instance using a Prometheus CRD defined in a YAML file named prometheus_instance.yaml 
Then, run the following: 
```bash
kubectl apply -f prometheus_instance.yaml
```
In the YAML file above, the serviceAccountName references the ServiceAccount you created earlier for the ClusterRoleBinding. serviceMonitorSelector points to a ServiceMonitor that allows Prometheus to monitor specific services in your cluster. If you wanted Prometheus to select all existing ServiceMonitors, you’d assign {} to the serviceMonitorSelector key; if you didn’t want it to select any ServiceMonitor, you wouldn’t include it in the Prometheus CRD.
To select a particular ServiceMonitor, use something like this:
serviceMonitorSelector:
    matchLabels:
      app: frontend
      
After you apply the prometheus_instance.yaml file, a prometheus-operated service is created, which you can see when you run kubectl get svc.
Now, access the server by forwarding a local port to the Prometheus service:
kubectl port-forward svc/prometheus-operated 9090:9090
Open the URL http://localhost:9090 in your browser to see a page similar to the image below:
 
Configuring Prometheus to monitor services and applications
In a cluster with many different applications running simultaneously, you might not want a single Prometheus instance scraping metrics from all of them. You likely have specific applications in mind that you want to scrape metrics from, and you can specify them with the ServiceMonitor CRD.
The ServiceMonitor CRD enables you to customize how you want Prometheus to operate in terms of scraping metrics. You can configure Prometheus to scrape metrics from all services that match the label Frontend or Staging. You can even configure the interval rate at which Prometheus scrapes metrics from a set of services. The ServiceMonitor CRD gives you enormous power over how Prometheus monitors services in your cluster.
Create a ServiceMonitor CRD
Next, you’re going to create an example ServiceMonitor CRD using the file named service_monitor.yaml 

The code tells Prometheus to scrape services with the operated-prometheus: "true" label every thirty seconds, which you can access on the /metrics endpoint. Additionally, this means that Prometheus will scrape its own data and monitor its own health. It is also important to note that you should change the key-values of the matchLabels which is operated-prometheus: “true” to the service labels you want to monitor. The matchLabels key-value is just an example for this article.
Apply it to your Kubernetes cluster by running the following command:
```bash
kubectl apply -f service_monitor.yaml
```
Configuring Prometheus Operator using CRD objects
The Prometheus Operator provides different types of CRDs you can apply in your Kubernetes cluster to manage your Prometheus application. Some already mentioned in this guide include the Prometheus CRD and the ServiceMonitor CRD. Other options include PrometheusRules, Alertmanager, and PodMonitor. You can read more on the other CRD objects in the Github documentation.
Deploying Grafana in your Kubernetes cluster
Next, let’s review how to deploy Grafana in Kubernetes. Grafana allows you to query, visualize, alert on, and understand your metrics no matter where they are stored.
In your terminal, run the following command:
```bash
kubectl create deployment grafana --image=docker.io/grafana/grafana:latest
```
You can run 
```bash
kubectl get deployments
```
to confirm that Grafana has been deployed:
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
grafana               1/1     1            1           5m27s
Next, you’ll create a service for the Grafana deployment:
```bash
kubectl expose deployment grafana --port 3000
```

Forward the port 3000 to the service by running the command below:
```bash
kubectl port-forward svc/grafana 3000:3000
```
Open http://localhost:3000 in your browser to access your Grafana dashboard. Log in with admin as the username and password. This redirects you to a page where you’ll be asked to change your password; afterward, you’ll see the Grafana homepage:
 
 ![kube1](https://github.com/Desmondotutu/Kubernetes-prometheus-grafana/assets/101313999/6dfd9faa-9f3c-456a-9b85-a43015bb4b06)

 
Click Data Sources, then select Prometheus and fill in your configuration details, such as your Prometheus Server URL, access, auth type, and scrape intervals.
You can’t use http://localhost:9090 as your HTTP URL because Grafana won’t have access to it. You must expose prometheus using a NodePort or LoadBalancer.
Use the file named expose_prometheus.

Run  
```bash 
kubectl apply -f expose_prometheus.yaml 
``` 
Grafana will be able to pull the metrics 
---
from http://<node_ip>:30900. To view the <node_ip>, run kubectl get nodes -o wide.
Enter http://<node_ip>:30900 in the URL box, then click Save & Test:
---
![kube2](https://github.com/Desmondotutu/Kubernetes-prometheus-grafana/assets/101313999/8ada7f82-ec66-4432-bdc5-3f9b484b191d)

---
Creating a Grafana dashboard to monitor Kubernetes events
---
Let’s create a dashboard that shows a graph for the total number of Kubernetes events handled by a Prometheus pod. Hover over the panel on the left of the screen and select Dashboards > New dashboard, then select Add a new panel.
Select Prometheus as your Data source, choose prometheus_sd_kubernetes_events_total for the metric and prometheus-prometheus-0 in the labels input or you can choose any metric and labels you want to monitor. Then, click Run queries:

![kube3](https://github.com/Desmondotutu/Kubernetes-prometheus-grafana/assets/101313999/9978c7c8-d8f3-4afc-8da0-94483dfd767c)
 
On the right-hand side of the dashboard panel configuration, you can configure details such as graph styles, the position of legends, and the title of the graph:
Click Apply once you’re done. You’ll be redirected to a new page containing your dashboard. You can add more dashboard panels by clicking the Add panel button or finish creating your dashboard by clicking the Save dashboard button:
 
 ![kube4](https://github.com/Desmondotutu/Kubernetes-prometheus-grafana/assets/101313999/4bf5972a-7a8d-4b46-ab78-02b21fd6677f)
 
Click the Save button to save your dashboard with a custom name:
 
 ![kube5](https://github.com/Desmondotutu/Kubernetes-prometheus-grafana/assets/101313999/5083bd21-8313-4bf3-be5f-7d2691f28a47)
Now that your dashboard is configured, you can add as many panels as you want to monitor different metrics scraped from your Prometheus instance in your cluster:
![kube7](https://github.com/Desmondotutu/Kubernetes-prometheus-grafana/assets/101313999/9791b85a-c4ab-48df-ad45-63074dad6ee9)
 
 ![kube8](https://github.com/Desmondotutu/Kubernetes-prometheus-grafana/assets/101313999/0b6cbbeb-76c7-43a6-bebe-d34d71d7bde2)

---
Conclusion
---
We have successfully setup Prometheus and Grafana to monitor our Kubernetes cluster.
