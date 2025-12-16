Setup:
- docker build -t fastapi-fastai:latest .

Run:
- docker run --rm -p 8000:8000 -e MODEL_PATH=product_classifier.pkl fastapi-fastai:latest

Test:
- curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"text": "Celine Tank Top White with Black Stripes Size S"}'
- curl -s -o /dev/null -w "Total time: %{time_total} seconds\n" -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"text": "Celine Tank Top White with Black Stripes Size S"}'

Test in Production:
- curl -X POST http://54.169.140.193:8000/predict -H "Content-Type: application/json" -d '{"text": "Celine Tank Top White with Black Stripes Size S"}'
- curl -s -o /dev/null -w "Total time: %{time_total} seconds\n" -X POST http://54.169.140.193:8000/predict -H "Content-Type: application/json" -d '{"text": "Celine Tank Top White with Black Stripes Size S"}'

Deploy to production (EC2 instance):
- Name: AI Product Classifier Experiment
- Quick Start: Ubuntu Server 24.04 LTS 64-bit
- Instance type: t3.small
  - 0.0208 * 24 * 31 = 15.4752 USD / month
- Key pair: dashboard-ec2-key-pair.pem (existing. don't create a new keypair)
- Network settings: use existing launch-wizard-1 security group
- 20 GiB gp3
  - $0.08/GB-month * 20 = 1.6 USD / month
- Number of instances: 1
- Finally, click Launch instance
  - https://ap-southeast-1.console.aws.amazon.com/ec2/home?region=ap-southeast-1#InstanceDetails:instanceId=i-0c102e95378bc09b6

Setup instance (based on Dockerfile):
- Copy files:
  - `scp -i "~/Downloads/dashboard-ec2-key-pair.pem" ./app_fastai.py ubuntu@ec2-54-169-140-193.ap-southeast-1.compute.amazonaws.com:~`
  - `scp -i "~/Downloads/dashboard-ec2-key-pair.pem" ./product_classifier.pkl ubuntu@ec2-54-169-140-193.ap-southeast-1.compute.amazonaws.com:~`
  - `scp -i "~/Downloads/dashboard-ec2-key-pair.pem" ./requirements.txt ubuntu@ec2-54-169-140-193.ap-southeast-1.compute.amazonaws.com:~`
- Connect to the instance using SSH
  - ssh -i "~/Downloads/dashboard-ec2-key-pair.pem" ubuntu@ec2-54-169-140-193.ap-southeast-1.compute.amazonaws.com
  - sudo su
    - sudo apt-get update && apt-get install -y --no-install-recommends \ build-essential \ git \ curl \ ca-certificates \ && rm -rf /var/lib/apt/lists/*
    - exit
  - vi ~/.bashrc
    - append these:
      - export PYTHONDONTWRITEBYTECODE=1
      - export PYTHONUNBUFFERED=1
      - export OMP_NUM_THREADS=1
      - export MKL_NUM_THREADS=1
    - quit and save
  - source ~/.bashrc
  - sudo apt update
  - sudo apt install -y python3-venv python3-full
  - python3 -m venv venv
  - source venv/bin/activate
    - pip install --upgrade pip
    - pip install --no-cache-dir -r requirements.txt
      - python --version
      - pip list
    - uvicorn app_fastai:app --host 0.0.0.0 --port 8000 --workers 1
      - don't forget to allow TCP port 8000 from Anywhere inbound rule in the launch-wizard-1 security group
