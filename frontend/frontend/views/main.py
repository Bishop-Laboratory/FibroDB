import flask
import frontend
import csv
import json
import math

@frontend.app.route('/', methods=['GET'])
def get_main_page():
    """Get search page information."""
    context = {}
    return flask.render_template('index.html', **context)

@frontend.app.errorhandler(404)
def reroute(e):
    return flask.render_template('index.html')