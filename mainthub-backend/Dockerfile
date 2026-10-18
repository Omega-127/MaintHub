FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN python -c "import uuid; open('build_id.txt', 'w').write(uuid.uuid4().hex)"

ENV PORT=5000

CMD ["sh", "-c", "gunicorn run:app --bind 0.0.0.0:${PORT:-5000}"]
