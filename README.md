# Laravel, ECS and AWS SSM Parameter Store
Use this laravel repository as the container source. In .env file we have `MY_CUSOTM_VAR="Default Value"` which is referenced in web.php. In local env and also ECS by default `Default Value` should be displayed if you navigate to `/check2`. To override this on local machine we need to pass env variable while running the docker container, and for on ECS we override it using AWS SSM Parameter Store.

Consdier the name of container is `test-container`. 

To build docker image:
```
docker build -t test-container:{VERSION} .
```

To run container image locally:
```
docker run -e MY_CUSOTM_VAR=OVERRIDEN -d --publish 8888:8000 test-container:{VERSION}
```
We have passed the env variable `MY_CUSOTM_VAR` another value `OVERRIDEN` which overrides the default value in .env file. 

Now see `http://127.0.0.1:8888/check2`

Now to see this on ECS first we need to upload the image to ECR. Considering we have already built the image locally, follow:

1. Login to ECR
```
aws ecr get-login-password --region {REGION} | docker login --username AWS --password-stdin {ACCOUNT_ID}.dkr.ecr.{REGION}.amazonaws.com
```

2. Tag the version
```
docker tag test-container:{VERSION} {YOUR_ACCOUNT}.dkr.ecr.{YOUR_REGION}-1.amazonaws.com/{YOUR_REPO}:{YOUR_TAG}
```

3. Create a repo in ECR

4. Upload the image to the repo in ECR
```
docker push {YOUR_ACCOUNT}.dkr.ecr.{YOUR_REGION}.amazonaws.com/{YOUR_REPO}:{YOUR_TAG}
```

5. Create a parameter in AWS SSM Parameter Store. Choose the type as **secureString**. Note the name of the parameter as we need to pass it to ECS Task Definition.

6. Create a Cluster in ECS as EC2 Linux + Networking

7. Create a role for ECS Task. It should have `AmazonECSTaskExecutionRolePolicy` policy and following inline policy (to allow read from AWS SSM Parameter Store) attached to:
```
{
    "Version": "2012-10-17",
            "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter",
            ],
            "Resource": [
                "arn:aws:ssm:*:*:parameter/*"
            ]
        }
    ]
}
```

8. Create a task definition. In the container section put the Image as `{YOUR_ACCOUNT}.dkr.ecr.{YOUR_REGION}-1.amazonaws.com/{YOUR_REPO}:{YOUR_TAG}`, and add on env variable as `MY_CUSOTM_VAR` and choose `valueFrom` and put the name of parameter we created in AWS SSM Parameter Store. For the **Task execution role** select the role created above.

9. Run the task, and browse to `http://{CONTAINER_PUBLIC_IP}/check2`. You should see the value you have entered in AWS SSM Parameter Store's paramater. 

# Points to note
The override of env variables logic works based on the configuration of Laravel for DotEnv lib. Laravel has configured it in a way not to override the value of the env var if it already exists. Since ECS injects the AWS SSM Parameter Store's parameter before  running the container, hence we will get the Parameter Store's value. 

By default we will get the new value in tinker (not sure if that is the same with Artisan commands), but not in controllers. To have the Parameter Store env value to have persistent value and behvaiour everywhere, add this to `CMD` command in Dockerfil: `php artisan config:cache`
