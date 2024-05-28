# Define IAM users
resource "aws_iam_user" "sungkyu" {
    name = "sungkyu"
}

resource "aws_iam_user" "boondo" {
    name = "boondo"
}

# Define IAM groups
resource "aws_iam_group" "developers" {
    name = "developers"
}

# Define IAM group membership (add users to groups)
resource "aws_iam_group_membership" "developer_membership" {
    name = "developer_membership"
    users = [
        aws_iam_user.sungkyu.name,
        aws_iam_user.boondo.name
    ]
    group = aws_iam_group.developers.name
}

# Define IAM policies
resource "aws_iam_policy" "developer_policy" {
    name = "developer_policy"
    description = "Allow developers to describe EC2 instances"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "ec2:Describe*"
                ],
                Resource = "*"
            }
        ]
    })
}

# Attach policies to groups
resource "aws_iam_group_policy_attachment" "developer_group_policy_attachment" {
    group = aws_iam_group.developers.name
    policy_arn = aws_iam_policy.developer_policy.arn
}