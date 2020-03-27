from json import dumps as json_dumps

from airflow import models
from airflow.utils import db
from pytest import fixture


def airflow_db_backend():
    db.upgradedb()
    return 100


def airflow_connections():
    db.merge_conn(models.Connection(
        conn_id='https_conn',
        conn_type='https',
        host='www.google.com',
        port=443,
        extra=json_dumps({'param': 1, 'option': 2}),
    ))

    db.merge_conn(models.Connection(
        conn_id='postgres_conn',
        uri='postgresql+psycopg2://postgres:postgres@postgres:5432/postgres',
    ))


@fixture(scope='session', name='main_conf')
def setup_main_conf():
    airflow_db_backend()
    airflow_connections()

    models.Variable.set('key', 'value')
    models.Variable.set(
        'json_key',
        {
            'a': 1,
            'b': 2,
        },
        serialize_json=True,
    )

    return {}


@fixture(scope='session', name='dags')
def setup_dags(main_conf):
    _ = main_conf
    yield models.DagBag().dags
