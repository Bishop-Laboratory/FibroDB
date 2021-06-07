# Fibroblast-lncRNASeq-explorer
Flask app for exploring the fibroblast lncRNA-Seq dataset from Therkelsen et al. 2021

## Development guide

### Getting started:

1. Clone the repo

```shell
git clone https://github.com/Bishop-Laboratory/Fibroblast-lncRNASeq-explorer.git
```

3. Set up the virtual env

```shell
cd Fibroblast-lncRNASeq-explorer/
bash install.sh
```

3. Run the app

```shell
source env/bin/activate
pip install -e .
export FLASK_APP=fibrodb
export FLASK_ENV=development
flask run
```

4. Test the app with `pytest`:

```shell
pytest
```

5. Test the coverage:

```shell
coverage run -m pytest
```

6. To avoid conflicts, please develop in a different branch from main and then submit a PR. You can make a new branch locally
by using:
   
```shell
git checkout -b my_branch
```

7. When you write a new feature, please also write unit tests for that feature. Unit tests should be in the `tests/` 
directory and follow the pattern `test_*.py`. For more info on writing tests, 
please see [this guide](https://flask.palletsprojects.com/en/2.0.x/tutorial/tests/).
   
8. Submit a pull request to merge your changes into the main branch when you are ready! Make sure to request a review and
make sure that your unit tests are passing. New comits should trigger the GitHub testing workflow to run, so check the "Actions" panel to see if it is passing.

Finally, the source data can be found here: https://uthscsa.box.com/s/lgcymxl0jef9wnmvqpvd9v3ih8820ti6

Here is the direct link on AWS: https://fibrodb-data.s3-us-west-2.amazonaws.com/Fibroblast-Fibrosis.zip

And the manuscript is here: https://uthscsa.box.com/s/b1hg9urz7dollxkpisgcyfih0l9djm1v
