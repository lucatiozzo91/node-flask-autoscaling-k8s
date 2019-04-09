FROM python:3.6

WORKDIR /app

ADD requirements.txt /app

RUN pip install -r requirements.txt

ADD . /app/

EXPOSE 5000

ENV prometheus_multiproc_dir /tmp

# Start gunicorn
CMD ["gunicorn", "-c", "config.py","--workers", "1","--bind", "0.0.0.0:5000", "app:app"]

