# @summary Telegraf Lustre client health checks
#
# @param enabled
#   Enable or disable this health check
#
# @param script_cfg
#   Hash that controls the values for the script config file. See data/common.yaml for examples
#
# @param telegraf_cfg
#   Hash of key:value pairs passed to telegraf::input as options
#
# @example
#   include profile_lustre::telegraf::lustre_client_health
class profile_lustre::telegraf::lustre_client_health (
  Boolean $enabled,
  Hash    $script_cfg,
  Hash    $telegraf_cfg,
){

  #
  # Checks specific for this particular telegraf script
  #
  if ($enabled) and ($::profile_monitoring::telegraf::enabled) {
    $script_cfg.each | $cfg_parm, $cfg_parm_value | {
      if empty($cfg_parm_value) {
        notify { "WARNING: ${cfg_parm} is not set, so it not being monitored" : }
      }
    }
  }

  #
  # Templatized telegraf script with config
  #
  $script_base_name = 'lustre_client_health'
  $script_path = '/etc/telegraf/scripts/lustre'
  $script_extension = '.sh'
  $script_full_path = "${script_path}/${script_base_name}${script_extension}"
  $script_cfg_full_path = "${script_path}/${script_base_name}_config"

  include profile_monitoring::telegraf
  include ::telegraf

  if ($enabled) and ($::profile_monitoring::telegraf::enabled) {
    $ensure_parm = 'present'
  } else {
    $ensure_parm = 'absent'
  }

  # Create folder for telegraf lustre scripts
  $script_dir_defaults = {
    ensure => 'directory',
    owner  => 'root',
    group  => 'telegraf',
    mode   => '0750',
  }
  ensure_resource('file', $script_path , $script_dir_defaults)

  # Setup telegraf config
  $telegraf_cfg_final = $telegraf_cfg + { 'command' => $script_full_path }
  telegraf::input { $script_base_name :
    ensure      => $ensure_parm,
    plugin_type => 'exec',
    options     => [ $telegraf_cfg_final ],
    require     => File[$script_full_path],
  }

  # Setup the actual script
  $script_defaults = { source_path => $script_cfg_full_path,  }
  file { $script_full_path :
    ensure  => $ensure_parm,
    content => epp("${module_name}/${script_base_name}${script_extension}.epp", $script_defaults),
    mode    => '0750',
    owner   => 'root',
    group   => 'telegraf',
  }

  # Setup the scripts config file
  file { $script_cfg_full_path :
    ensure  => $ensure_parm,
    content => epp("${module_name}/${script_base_name}_config.epp", $script_cfg),
    owner   => 'root',
    group   => 'telegraf',
    mode    => '0740',
  }

}
