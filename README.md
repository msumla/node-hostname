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