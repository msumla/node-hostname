# node-hostname

A simple Node.js express web server that provides system information and demonstrates basic error handling.

## Features

- Returns system hostname and application version
- Includes error handling demonstration
- RESTful API endpoints

## API Endpoints

- `GET /` - Returns system hostname and application version
  ```json
  {
    "hostname": "your-hostname",
    "version": "0.0.1"
  }
  ```
- `GET /users` - Returns a simple resource message
- `GET /crash` - Demonstrates error handling (intentionally crashes)

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd node-hostname

# Install dependencies
npm install
```

## Docker

### Building the Image

```bash
# Build the Docker image
docker build -t node-hostname .
```

### Running with Docker

```bash
# Run the container
docker run -p 3000:3000 node-hostname
```

The application will be available at `http://localhost:3000`.

### Environment Variables

You can customize the port by setting the `PORT` environment variable:

```bash
docker run -p 8080:8080 -e PORT=8080 node-hostname
```

## Usage

Start the server:
```bash
npm start
```

The server will start on port 3000 by default. You can change this by setting the `PORT` environment variable.

## Development

To run the application in development mode:

```bash
# Install dependencies
npm install

# Start the server
npm start
```

The server will automatically restart when you make changes to the code.

## Error Handling

The application includes built-in error handling that returns JSON responses for:
- 404 Not Found errors
- 500 Internal Server errors

Error responses follow this format:
```json
{
  "error": {
    "message": "Error message",
    "status": 404
  }
}
```

## Dependencies

- express: Web framework
- morgan: HTTP request logger
- debug: Debug utility
- http-errors: HTTP error handling
- cookie-parser: Cookie parsing middleware

## CI/CD Setup

This project uses GitHub Actions for continuous integration and deployment. The workflows are configured to build, test, and deploy the application to Google Kubernetes Engine (GKE).

### Prerequisites

1. A Google Cloud Platform (GCP) project
2. A GKE cluster
3. A GitHub repository
4. Required GCP permissions

### Setting up GCP Service Account

1. Create a service account for GitHub Actions:
```bash
gcloud iam service-accounts create github-actions \
    --description="Service account for GitHub Actions" \
    --display-name="GitHub Actions"
```

2. Grant necessary roles to the service account:
```bash
gcloud projects add-iam-policy-binding bwt-test-460814 \
    --member="serviceAccount:github-actions@bwt-test-460814.iam.gserviceaccount.com" \
    --role="roles/container.admin"

gcloud projects add-iam-policy-binding bwt-test-460814 \
    --member="serviceAccount:github-actions@bwt-test-460814.iam.gserviceaccount.com" \
    --role="roles/storage.admin"
```

3. Create and download the service account key:
```bash
gcloud iam service-accounts keys create key.json \
    --iam-account=github-actions@bwt-test-460814.iam.gserviceaccount.com
```

### GitHub Secrets Setup

Add the following secrets to your GitHub repository (Settings > Secrets and variables > Actions):

- `GCP_PROJECT_ID`: Your GCP project ID (e.g., `bwt-test-460814`)
- `GCP_SA_KEY`: The entire contents of the `key.json` file
- `GKE_CLUSTER`: Your GKE cluster name (e.g., `bwt-test-cluster`)
- `GKE_ZONE`: Your GKE cluster zone (e.g., `europe-north1`)

### Workflows

The repository includes three GitHub Actions workflows:

1. **Pull Request Workflow** (`.github/workflows/pr.yml`)
   - Triggers on pull requests to main branch
   - Builds and tests the application
   - Creates a preview deployment

2. **Deploy Workflow** (`.github/workflows/deploy.yml`)
   - Triggers on pushes to main branch
   - Builds and tests the application
   - Pushes Docker image to Google Container Registry
   - Deploys to GKE using Kustomize

3. **Revert Workflow** (`.github/workflows/revert.yml`)
   - Triggers when a pull request is closed
   - Reverts the deployment if needed

### Manual Deployment

To deploy manually:

```bash
# Build and push the Docker image
docker build -t gcr.io/bwt-test-460814/node-hostname:latest .
docker push gcr.io/bwt-test-460814/node-hostname:latest

# Deploy using Kustomize
cd kubernetes/overlays/prod
kustomize edit set image gcr.io/bwt-test-460814/node-hostname:latest
kubectl apply -k .
```

### Monitoring Deployments

Check deployment status:
```bash
# Check pods
kubectl get pods -n bwt-test-namespace -l app=node-hostname

# Check deployment
kubectl get deployment -n bwt-test-namespace bwt-test-node-hostname

# Check ingress
kubectl get ingress -n bwt-test-namespace bwt-test-node-hostname
```

### Troubleshooting

1. **Authentication Issues**
   - Verify GCP service account key is correctly set in GitHub secrets
   - Check service account has required permissions
   - Ensure GKE cluster credentials are up to date

2. **Deployment Failures**
   - Check pod logs: `kubectl logs -n bwt-test-namespace -l app=node-hostname`
   - Verify image exists in GCR: `gcloud container images list-tags gcr.io/bwt-test-460814/node-hostname`
   - Check ingress status: `kubectl describe ingress -n bwt-test-namespace bwt-test-node-hostname`

3. **Workflow Failures**
   - Check GitHub Actions logs for detailed error messages
   - Verify all required secrets are set
   - Ensure workflow files are in the correct location (`.github/workflows/`)