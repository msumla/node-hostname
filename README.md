# Node Hostname Service

A simple Node.js service that returns the hostname of the container it's running in. This is useful for testing load balancing and pod distribution in Kubernetes.

## Features

- Returns container hostname on HTTP GET requests
- Health check endpoint at `/`
- Configurable port (default: 3000)
- Docker container support
- Kubernetes deployment with Kustomize
- GitHub Actions CI/CD pipeline

## Prerequisites

- Node.js 20.x
- Docker
- Google Cloud Platform account
- GKE cluster
- GitHub repository

## Local Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Run the service:
   ```bash
   npm start
   ```

3. Test the service:
   ```bash
   curl http://localhost:3000
   ```

## Docker

Build and run the Docker container:

```bash
docker build -t node-hostname .
docker run -p 3000:3000 node-hostname
```

## Kubernetes Deployment

The application is deployed to GKE using Kustomize. The deployment configuration is in the `kubernetes` directory:

- `kubernetes/base/` - Base configuration
- `kubernetes/overlays/prod/` - Production environment configuration

### Resource Requirements

- Memory: 2Gi
- CPU: 500m
- Replicas: 2

## CI/CD Pipeline

The project uses GitHub Actions for CI/CD with the following workflows:

### Pull Request Workflow

- Triggers on PR creation to master
- Builds and tests the application
- Builds and pushes Docker image to GCR
- Uses Workload Identity Federation for GCP authentication

### Deploy Workflow

- Triggers on push to master
- Builds and pushes Docker image to GCR
- Deploys to GKE using Kustomize
- Uses Workload Identity Federation for GCP authentication

### Revert Process

To revert a deployment:
1. Create a PR that reverts the previous commit
2. When merged, the deploy workflow will automatically deploy the previous version
3. The workflow uses the commit SHA to reference the correct Docker image

## GCP Setup

1. Create a Workload Identity Pool and Provider:
   ```bash
   gcloud iam workload-identity-pools create github-pool \
     --location="global" \
     --display-name="GitHub Pool"

   gcloud iam workload-identity-pools providers create-oidc github-provider \
     --location="global" \
     --workload-identity-pool="github-pool" \
     --display-name="GitHub Provider" \
     --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor,attribute.repository_owner=assertion.repository_owner" \
     --issuer-uri="https://token.actions.githubusercontent.com"
   ```

2. Create a service account with necessary permissions:
   ```bash
   gcloud iam service-accounts create github-actions-sa \
     --display-name="GitHub Actions Service Account"

   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:github-actions-sa@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/artifactregistry.writer"

   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:github-actions-sa@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/container.developer"

   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:github-actions-sa@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/container.clusterViewer"
   ```

3. Allow GitHub to impersonate the service account:
   ```bash
   gcloud iam service-accounts add-iam-policy-binding github-actions-sa@$PROJECT_ID.iam.gserviceaccount.com \
     --role="roles/iam.workloadIdentityUser" \
     --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/$REPO_OWNER/$REPO_NAME"
   ```

## GitHub Repository Setup

Required secrets:
- `GCP_PROJECT_ID`: Your GCP project ID
- `GKE_CLUSTER`: Your GKE cluster name
- `GKE_ZONE`: Your GKE cluster zone

## License

MIT