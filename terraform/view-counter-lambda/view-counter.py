import boto3
import json

# Get the service resource.
dynamodb = boto3.resource("dynamodb")

# Instantiate a table resource object without actually
# creating a DynamoDB table. Note that the attributes of this table
# are lazy-loaded: a request is not made nor are the attribute
# values populated until the attributes
# on the table resource are accessed or its load() method is called.
table = dynamodb.Table("lukelearnsthe.cloud")


# get current views
def lambda_handler(event, context):
    response = table.get_item(
        Key={
            "id": "0",
        }
    )
    views = response["Item"]["views"]

    # increment views by 1
    views = views + 1
    print(views)

    response = table.put_item(Item={"id": "0", "views": views})

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"views": str(views)}),
    }
