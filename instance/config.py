"""Flask configuration."""

TESTING = True
DEBUG = True
FLASK_ENV = 'development'
SECRET_KEY = 'GDtfDCFYjD'
SQLALCHEMY_DATABASE_URI = 'sqlite:///fibrodb.db'
SQLALCHEMY_TRACK_MODIFICATIONS = True
