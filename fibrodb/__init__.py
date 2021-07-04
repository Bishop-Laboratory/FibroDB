import os
from flask import Flask


def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    # Init database with app
    from fibrodb.model import db
    db.init_app(app)

    # Clean the database and load it
    from fibrodb.db import clean_init_db
    with app.app_context():
        clean_init_db(db)

    # For testing
    @app.route("/hello")
    def hello():
        return "Hello world!"

    return app
