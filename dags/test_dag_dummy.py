from airflow.utils import timezone
from airflow.models import DAG
from airflow.operators.dummy_operator import DummyOperator


DEFAULT_ARGS=dict(
    start_date=timezone.datetime(2016, 1, 1),
    owner='Test',
    retries=0,
    depends_on_past=False,
)

with DAG(
    'test_dag_dummy',
    catchup=False,
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
    is_paused_upon_creation=True,
) as dag:
    task1 = DummyOperator(task_id='task1')
    task2 = DummyOperator(task_id='task2')
    task3 = DummyOperator(task_id='task3')

    task1 >> task2 >> task3
