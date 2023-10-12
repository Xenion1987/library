# library

Storing some code examples and one-line-scripts

## Get installed, started but not enabled services

```sh
grep -f <(awk '$0 ~ /(.*)\.service/ {print $1}'< <(systemctl --no-pager list-unit-files --type=service --state=disabled))< <(awk '$0 ~ /(.*)\.service/ {print $1}'< <(systemctl --no-pager list-units --type=service --state=running))
```
