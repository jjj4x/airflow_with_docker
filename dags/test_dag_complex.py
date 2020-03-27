from logging import getLogger

from airflow.utils import timezone
from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator

log = getLogger(__name__)


def pushes_a_value(**context):
    log.info('Doing things')
    context['ti'].xcom_push('some', {'my dict': 100, 'ключ': 'значение'})
    context['ti'].xcom_push('нечто', 'ну как бы некий текст')


def pulls_the_value(**context):
    value = context['ti'].xcom_pull(
        key='some',
        task_ids='pushing_task'
    )
    log.info(f'The value is: {value}')


DEFAULT_ARGS=dict(
    start_date=timezone.datetime(2016, 1, 1),
    owner='Test',
    retries=0,
    depends_on_past=False,
)

with DAG(
    'test_dag_complex',
    catchup=False,
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
    is_paused_upon_creation=True,
) as dag:
    bash_task = BashOperator(
        task_id='bash_task',
        bash_command="""
            for i in {00..09}; do
                echo "Iterating with $i"
            done
        """,
    )
    pushing_task = PythonOperator(
        task_id='pushing_task',
        python_callable=pushes_a_value,
        provide_context=True,
    )
    pulling_task = PythonOperator(
        task_id='pulling_task',
        python_callable=pulls_the_value,
        provide_context=True,
    )

    bash_task >> pushing_task >> pulling_task
