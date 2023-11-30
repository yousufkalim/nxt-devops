# Create a user pool
resource "aws_cognito_user_pool" "auth_pool" {
  name              = "nxt-user-pool"
  auto_verified_attributes = ["email"]
}

# User pool client
resource "aws_cognito_user_pool_client" "userpool_client" {
  name                                 = "client"
  user_pool_id                         = aws_cognito_user_pool.auth_pool.id
  callback_urls                        = ["https://example.com"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}

# Identity pool
resource "aws_cognito_identity_pool" "auth_identity_pool" {
  identity_pool_name               = "identity pool"
  allow_unauthenticated_identities = false
}
