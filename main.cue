package apptpl

// Deployment template containing all the common boilerplate shared by
// deployments of this application.
#Deployment: {
    // Name of the deployment. This will be used to label resources automatically
    // and generate selectors.
    name: string

    // Container image.
    image: string

    // 80 is the default port.
    port: *80 | int

    // 1 is the default, but we allow any number.
    replicas: *1 | int

    // Deployment manifest. Uses the name, image, port and replicas above to
    // generate the resource manifest.
    manifest: {
        apiVersion: "apps/v1"
        kind:       "Deployment"
        metadata: {
            "name": name
            labels: app: name
        }
        spec: {
            "replicas": replicas
            selector: matchLabels: app: name
            template: {
                metadata: labels: app: name
                spec: containers: [{
                    "name":  name
                    "image": image
                    ports: [{
                        containerPort: port
                    }]
                }]
            }
        }
    }
}

// Service template containing all the common boilerplate shared by
// services of this application.
#Service: {
    // Name of the service. This will be used to label resources automatically
    // and generate selector.
    name: string

    // NodePort is the default service type.
    type: *"NodePort" | "LoadBalancer" | "ClusterIP" | "ExternalName"

    // Ports where the service should listen
    ports: [string]: number

    // Service manifest. Uses the name, type and ports above to
    // generate the resource manifest.
    manifest: {
        apiVersion: "v1"
        kind:       "Service"
        metadata: {
            "name": "\(name)-service"
            labels: app: name
        }
        spec: {
            "type": type
            "ports": [
                for k, v in ports {
                    name: k
                    port: v
                },
            ]
            selector: app: name
        }
    }
}

// Define and generate kubernetes deployment to deploy to kubernetes cluster
#AppManifest: {
    // Name of the application
    name: string

    // Image to deploy to
    image: string

    // Define a kubernetes deployment object
    deployment: #Deployment & {
        "name":  name
        "image": image
    }

    // Define a kubernetes service object
    service: #Service & {
        "name": name
        ports: http: deployment.port
    }

    // Merge definitions and convert them back from CUE to YAML
    manifest: yaml.MarshalStream([deployment.manifest, service.manifest])
}
