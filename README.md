# CI/CD Pipeline with GitHub Actions, Docker Hub, and Microsoft Azure Kubernetes

## **Step 1: Set Up Your GitHub Repository**

1. Go to **[GitHub](https://github.com)**.
2. Click on **"New Repository"**.
3. **Set the repository name**: `ci_cd_demo`.
4. **Set repository visibility**: Choose `Public` or `Private`.
5. **Initialize the repository with a README** (optional).
6. Click **"Create Repository"**.


## **Step 2: Clone the Repository and Create Project Structure**

1. Open **Git Bash** or **Terminal**.
2. Clone the repository:
   ```bash
   git clone https://github.com/<your-github-username>/ci_cd_demo.git
   cd ci_cd_demo
   ```
3. Create the necessary folders and files:
   ```bash
   mkdir src tests k8s .github/workflows
   touch src/main.py tests/test_main.py requirements.txt Dockerfile k8s/deployment.yml k8s/service.yml .github/workflows/ci.yml README.md
   ```
4. Your project structure should look like this:
   ```plaintext
   ci_cd_demo/
   ├── src/                     
   │   ├── main.py              
   ├── tests/                  
   │   ├── test_main.py         
   ├── requirements.txt         
   ├── Dockerfile              
   ├── .github/                
   │   ├── workflows/
   │       ├── ci.yml           
   ├── k8s/                   
   │   ├── deployment.yml      
   │   ├── service.yml          
   ├── README.md               
   ```


## **Step 3: Write Python Application and Tests**

### **1. Create the Application Code (`src/main.py`)**
```python
def add(a, b):
    """Function to add two numbers."""
    return a + b

if __name__ == "__main__":
    print(f"2 + 3 = {add(2, 3)}")
```

### **2. Write Unit Tests (`tests/test_main.py`)**
```python
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from src.main import add

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0
```

### **3. Define Dependencies (`requirements.txt`)**
```plaintext
pytest
```

### **4. Test the Application Locally**
```bash
python -m venv venv
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate     # Windows

pip install -r requirements.txt
pytest
```


## **Step 4: Containerize the Application Using Docker Hub**

But we'll push the image to **Docker Hub**.

### **1. Create the `Dockerfile`**
```Dockerfile
# Use an official Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY src/ src/
COPY tests/ tests/
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Run tests when the container starts
CMD ["pytest"]
```

### **2. Log in to Docker Hub**
```bash
docker login -u <your-dockerhub-username>
```

### **3. Build and Push the Image to Docker Hub**
```bash
docker build -t <your-dockerhub-username>/ci_cd_demo .
docker push <your-dockerhub-username>/ci_cd_demo
```


## **Step 5: Configure GitHub Actions for CI/CD**

GitHub Actions will automate testing, building, and deployment.

### **1. Create the Workflow (`.github/workflows/ci.yml`)**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: 3.9

    - name: Install dependencies
      run: pip install -r requirements.txt

    - name: Run tests
      run: pytest

    - name: Log in to Docker Hub
      run: echo "${{ secrets.DOCKERHUB_PASSWORD }}" | docker login -u "${{ secrets.DOCKERHUB_USERNAME }}" --password-stdin

    - name: Build and Push Docker Image
      run: |
        docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/ci_cd_demo .
        docker push ${{ secrets.DOCKERHUB_USERNAME }}/ci_cd_demo
```

### **2. Add Secrets to GitHub**

1. Go to **GitHub Repository** → **Settings** → **Secrets** → **Actions**.
2. Add the following secrets:
   - **DOCKERHUB_USERNAME** = `<your-dockerhub-username>`
   - **DOCKERHUB_PASSWORD** = `<your-dockerhub-password>`

### **3. Push Your Code to GitHub**
```bash
git add .
git commit -m "Add CI/CD pipeline"
git push -u origin main
```


## **Step 6: Deploy to Microsoft Azure Kubernetes**

### **1. Set Up Azure Kubernetes Service (AKS)**

1. Go to **Azure Portal** → [Azure Kubernetes Service](https://portal.azure.com/).
2. Create a new AKS cluster:
   - Set a name for your cluster.
   - Choose your resource group.
   - Select node size and node count.
3. Wait for the cluster to be provisioned.

### **2. Install `kubectl` and Connect to the Cluster**
```bash
az aks install-cli
az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
```

### **3. Create Kubernetes Manifests**

#### **Deployment (`k8s/deployment.yml`)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ci-cd-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ci-cd-demo
  template:
    metadata:
      labels:
        app: ci-cd-demo
    spec:
      containers:
      - name: ci-cd-container
        image: <your-dockerhub-username>/ci_cd_demo:latest
        ports:
        - containerPort: 80
```

#### **Service (`k8s/service.yml`)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: ci-cd-service
spec:
  type: LoadBalancer
  selector:
    app: ci-cd-demo
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

### **4. Deploy to Kubernetes**
```bash
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
```

### **5. Verify Deployment**
```bash
kubectl get pods
kubectl get services
```

### **6. Access the Application**

1. Note the external IP from the `kubectl get services` command.
2. Access the application in your browser using the external IP.


## **Conclusion**

You have successfully built and deployed a Python application using a CI/CD pipeline with GitHub Actions, Docker Hub, and Kubernetes on Azure. The pipeline automates testing, building, and deploying your application to a scalable cloud environment.
