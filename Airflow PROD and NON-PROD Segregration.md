This is a plan to segregate Airflow into PROD and NON-PROD

Before we start
Get github actions working
Test github runners and stop using INF-CICD-1
Get approval from ALdo for github runners

First step.
Get all Airflow instances upgraded to 3.11
Detail noty included since it will be another task and document

Then
Build two replacement servers 
INF-SCHEDULER-1 and INF-SCHEDULER-2
Both Ubuntu 16
Test both with dummy DAGS
Get github actions and runners working with both servers
Create two new repos

Then
Migrate all DAGs to INF-SCHEDULER-2
Also all connections and variables
Shutdwon INF-CONTROL-1

Then
Migrate INF-SCHEDUELR-1 to ISM
Wait for them to do it

THen 
Migrate functionality from -2 to -1
Remove orhpaned connections and variables from  -2



MY NOTES

Here's the problem - some is PROD (Archive) some is NON-PROD(Archive)  some is INF (Veeam)