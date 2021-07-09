export FLASK_APP=fibrodb
export FLASK_ENV=development
flask run
cd frontend
export FLASK_APP=frontend
flask run --port 5001
