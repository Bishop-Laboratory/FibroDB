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


@frontend.app.route('/api', methods=['GET'])
def get_data():
    """Sample data getter for volcano plot"""
    with open('frontend/static/js/data_for_volcano.tsv') as file:
        reader = csv.DictReader(file, delimiter="\t")
        data = list(reader)[:1000]
        data = {k: [dic[k] for dic in data] for k in data[0]}
        data['FDR'] = [str(-1*math.log(float(datum))) for datum in data['FDR'] if float(datum) != 0]
        return data
    
@frontend.app.route('/info', methods=['GET'])
def get_prot_data():
    """Sample data getter for volcano plot"""
    protname = flask.request.args.get('name')
    with open('frontend/static/js/data_for_volcano.tsv') as file:
        reader = csv.DictReader(file, delimiter="\t")
        data = list(reader)
        data = [elem for elem in data if elem["Gene Symbol"]==protname]
        return data[0]