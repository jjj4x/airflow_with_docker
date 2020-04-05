from collections import Mapping

from airflow import models
from airflow.utils import db, timezone


def test_main_conf(main_conf):
    assert isinstance(main_conf, Mapping)


def test_connections(main_conf):
    _ = main_conf
    with db.create_session() as session:
        https_conn, postgres_conn = session.query(models.Connection).all()
        assert https_conn.get_uri() == 'https://www.google.com:443?param=1&option=2'
        assert postgres_conn.port == 5432


def test_variables(main_conf):
    _ = main_conf
    var1 = models.Variable.get('key')
    var2 = models.Variable.get('json_key', deserialize_json=True)

    assert var1 == 'value'
    assert var2['a'] == 1



def test_dag_dummy(dags):
    assert 'test_dag_dummy' in dags

    dag: models.DAG = dags['test_dag_dummy']

    assert len(dag.topological_sort()) == 3

    dag.clear()
    dag.run()


def test_dag_bash(dags):
    assert 'test_dag_bash' in dags

    dag: models.DAG = dags['test_dag_bash']
    assert len(dag.topological_sort()) == 2

    dag.clear()
    dag.run()

def test_dag_complex(dags):
    assert 'test_dag_complex' in dags

    dag: models.DAG = dags['test_dag_complex']
    assert len(dag.topological_sort()) == 3

    dag.clear()
    dag.run()

    # test unicode support
    value = models.XCom.get_one(
        execution_date=timezone.datetime(2016, 1, 1),
        key='нечто',
        task_id='pushing_task',
        dag_id='test_dag_complex',
    )
    assert value == 'ну как бы некий текст'
