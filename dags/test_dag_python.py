from logging import getLogger

from airflow.utils import timezone
from airflow.models import DAG
from airflow.operators.python_operator import PythonOperator

log = getLogger(__name__)


def printer(*args, **kwargs):
    log.info(f'Like, you know, printing... {args} and {kwargs}')


def dummy(*args, **kwargs):
    log.info('Dummy')
    printer(*args, **kwargs)


DEFAULT_ARGS=dict(
    start_date=timezone.datetime(2016, 1, 1),
    owner='Test',
    retries=0,
    depends_on_past=False,
)

with DAG(
    'test_dag_python',
    catchup=False,
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
    is_paused_upon_creation=True,
) as dag:
    printer_task = PythonOperator(
        task_id='printer',
        python_callable=printer,
    )
    dummy_task = PythonOperator(
        task_id='dummy',
        python_callable=dummy,
    )
    printer_task >> dummy_task
