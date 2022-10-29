FROM python:3

EXPOSE 8000
COPY app.py /app.py
COPY dto.py /dto.py
COPY requirements.txt /requirements.txt

ENV JAVA_HOME /usr/lib/jvm/java-1.7-openjdk/jre
RUN apt-get update && apt-get install -y g++ default-jdk
RUN pip install -r requirements.txt
CMD uvicorn app:app --reload --host 0.0.0.0 --port=8000