Setup:
- docker build -t fastai-text-fastapi:latest .

Run:
- docker run --rm -p 8000:8000 -e MODEL_PATH=product_classifier.pkl fastai-text-fastapi:latest

Test:
- curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"text": "Celine Tank Top White with Black Stripes Size S"}'
- curl -s -o /dev/null -w "Total time: %{time_total} seconds\n" -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"text": "Celine Tank Top White with Black Stripes Size S"}'
