from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)
from werkzeug.exceptions import abort
from fibrodb.db import get_db

bp = Blueprint('webui', __name__)


@bp.route('/')
def home():
    return render_template('webui/home.html')


@bp.route('/deg-explorer')
def deg_explorer():
    db = get_db()
    # degs = db.execute(
    #     # TODO: SQL for selecting the DEGs to display
    # ).fetchall()
    degs = "Hello DEGs!"

    return render_template('webui/deg_explorer.html', degs=degs)


@bp.route('/downloads')
def downloads():
    return render_template('webui/downloads.html')


@bp.route('/help')
def helppage():
    return render_template('webui/help.html')


@bp.route('/api-ref')
def api_ref():
    return render_template('webui/api_ref.html')
