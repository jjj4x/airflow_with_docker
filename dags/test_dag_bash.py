from airflow.utils import timezone
from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator


DEFAULT_ARGS=dict(
    start_date=timezone.datetime(2016, 1, 1),
    owner='Test',
    retries=0,
    depends_on_past=False,
)

with DAG(
    'test_dag_bash',
    catchup=False,
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
    is_paused_upon_creation=True,
) as dag:
    task1 = BashOperator(
        task_id='task1',
        bash_command='echo The bash version is ${BASH_VERSION}; date',
    )
    task2 = BashOperator(
        task_id='task2',
        bash_command="""
            for i in {00..09}; do
                echo "Iterating with $i"
            done
        """,
    )
