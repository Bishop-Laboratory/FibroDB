import flask
import frontend


@frontend.app.route('/', methods=['GET'])
def get_main_page():
    """Get search page information."""
    context = {}
    return flask.render_template('index.html', **context)
