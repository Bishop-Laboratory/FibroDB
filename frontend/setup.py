from setuptools import setup

setup(
    name='frontend',
    version='1.0.0',
    packages=['frontend'],
    include_package_data=True,
    install_requires=[
        'Flask',
        'Flask-Testing',
        'nodeenv',
        'pycodestyle',
        'pydocstyle',
        'pylint',
        'pytest',
        'requests',
        'sh'
        ],
)