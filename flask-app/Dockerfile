FROM python:3.12-slim-bullseye

WORKDIR /flask-app

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

CMD [ "python3", "-m", "flask", "run", "--host=0.0.0.0", "--port=8080" ]

EXPOSE 8080