# Generate the zip file for the lambda function
data "archive_file" "lambda_view_counter" {
  type = "zip"

  source_dir  = "${path.module}/view-counter-lambda"
  output_path = "${path.module}/view-counter-lambda.zip"
}

# Upload the zip file to the website bucket
resource "aws_s3_object" "lambda_view_counter" {
  bucket = aws_s3_bucket.website.id

  key    = "view-counter-lambda.zip"
  source = data.archive_file.lambda_view_counter.output_path

  etag = filemd5(data.archive_file.lambda_view_counter.output_path)
}

resource "aws_lambda_function" "view_counter" {
  function_name = "ViewCounter"

  s3_bucket = aws_s3_bucket.website.id
  s3_key    = aws_s3_object.lambda_view_counter.key

  runtime = "python3.12"
  handler = "view-counter.lambda_handler"

  # will change whenever you update the code contained in the archive
  # lets Lambda know that there is a new version of your code available.
  source_code_hash = data.archive_file.lambda_view_counter.output_base64sha256

  # grants the function permission to access AWS services and resources in your account.
  role = aws_iam_role.lambda_exec.arn
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "view_counter" {
  name = "/aws/lambda/${aws_lambda_function.view_counter.function_name}"

  retention_in_days = 5
}

# allows Lambda to access resources in your AWS account.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

# policy for the lambda function to access the DynamoDB table
resource "aws_iam_role_policy" "dynamodb_lambda_policy" {
  name = "dynamodb_lambda_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
        ]
        Resource = aws_dynamodb_table.website.arn
      }
    ]
  })
}

# allows Lambda to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}