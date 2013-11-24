
all: pip s

s: 
	./manage.py runserver 0.0.0.0:8000

pip:
	pip install -r requirements.txt

des:
	pip install -r requeridos/des.txt
