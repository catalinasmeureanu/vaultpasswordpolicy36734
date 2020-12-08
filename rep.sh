vault server -dev -dev-root-token-id="root"&

sleep 2

export VAULT_ADDR='http://127.0.0.1:8200'

vault namespace create education

vault secrets enable -ns=education ad

tee policy.hcl <<EOF
length = 8
rule "charset" {
  charset = "abcdefghijklmnopqrstuvwxyz"
  min-chars = 1
}
rule "charset" {
  charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  min-chars = 1
}
rule "charset" {
  charset = "0123456789"
  min-chars = 1
}
rule "charset" {
  charset = "!@#$%^&*"
  min-chars = 1
}
EOF

vault write education/sys/policies/password/ad_policy  policy=@policy.hcl

vault write -namespace=education ad/config \
 binddn=vagrant bindpass=vagrant url=ldaps://WindowsDC.marti.local userdn='dc=marti,dc=local'\
 password_policy=ad_policy length=0

vault write -namespace=education ad/library/accounting-team service_account_names=catalina@marti.local

echo "The password policy is set at education/sys/policies/password/ad_policy":

vault read education/sys/policies/password/ad_policy
