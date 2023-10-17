
# Queue for Lambda API to put requests onto, for Lambda Proc to consume
resource "aws_sqs_queue" "requests" {
  name                        = "terraform-example-queue-${var.environment}.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}
