import sqlite3
import click
from flask import current_app, g
from flask.cli import with_appcontext


def init_db():
    db = get_db()

    with current_app.open_resource('schema.sql') as f:
        db.executescript(f.read().decode('utf8'))


@click.command('init-db')
@with_appcontext
def init_db_command():
    """Clear the existing data and create new tables."""
    init_db()
    click.echo('Initialized the database.')


def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect(
            current_app.config['DATABASE'],
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        g.db.row_factory = sqlite3.Row

        # TODO: Needs loading function
        # g.db = load_db(g.db)

    return g.db

def download_data(url):
    """
    Downloads zip file from given url, unzips it and saves unzipped content to 'data' directory
    """
    from io import BytesIO
    from urllib.request import urlopen
    from zipfile import ZipFile
    import os
    zipurl = url
    print(os.getcwd())
    print("[+] Opening ZIP file")
    with urlopen(zipurl) as zipresp:
        print("[+] Reading ZIP file")
        with ZipFile(BytesIO(zipresp.read())) as zfile:
            print("[+] ZIP file extracted to 'data' directory")
            zfile.extractall(f'data')

def load_db(db):
    """
    Calls download_data() to get data and loads data into DB.
    """
    download_data('https://fibrodb-data.s3-us-west-2.amazonaws.com/Fibroblast-Fibrosis.zip')

    ## Add code for data munging into DB here
    # return db

def close_db(e=None):
    db = g.pop('db', None)

    if db is not None:
        db.close()


def init_app(app):
    app.teardown_appcontext(close_db)
    app.cli.add_command(init_db_command)
