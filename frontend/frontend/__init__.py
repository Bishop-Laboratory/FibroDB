import flask

app = flask.Flask(__name__)
app.static_url_path='/static'
import frontend.views