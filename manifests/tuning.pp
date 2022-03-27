# @summary Apply Lustre tuning parameters using lctl.
#
# Apply Lustre tuning parameters using lctl.
#
# @param params
#   Hash of tuning parameters:
#     "<key1>": "<value1>"
#     "<key2>": "<value2">
#   Note: Keys may contain * as a wildcard. E.g.:
#     "osc.*.max_pages_per_rpc": "4096"
#
# @example
#   include profile_lustre::tuning
class profile_lustre::tuning (
  Hash $params,
) {

  $params.each | String $param, String $value | {
    $check_param_command = "lctl get_param -n ${param} | egrep -qv \"^${value}$\""
    $set_param_command = "lctl set_param ${param}=${value}"
    exec { $param:
      command => $set_param_command,
      onlyif  => $check_param_command,
      path    => ['/usr/bin', '/usr/sbin', '/sbin'],
    }

  }

}
