from datetime import datetime
from airflow.models.dag import DAG
from airflow.operators.python import PythonOperator


with DAG(
    dag_id="python_test",
    start_date=datetime(2023, 12, 24),
    schedule="@daily",
) as dag1:

    def test():
        print("hi")

    def test2():
        print("hi2")

    # [START task_outlet]
    t1 = PythonOperator(task_id="test", python_callable=test)

    t2 = PythonOperator(task_id="test2", python_callable=test2)

    t1 >> t2
