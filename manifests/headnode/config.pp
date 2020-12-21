# slurm/headnode/config.pp
#
# Ensures that the slurmctld service is running and restarted if the configuration file is modified.
#
# version 20170816
#
# Copyright (c) CERN, 2016-2017
# Authors: - Philippe Ganz <phganz@cern.ch>
#          - Carolina Lindqvist <calindqv@cern.ch>
#          - Pablo Llopis <pablo.llopis@cern.ch>
# License: GNU GPL v3 or later.
#

class slurm::headnode::config (
  Optional[String] $slurmctld_options = undef,
  Boolean $refresh_service = true,
) {

  if $slurmctld_options {
    file { "/etc/sysconfig/slurmctld":
      before  => Service["slurmctld"],
      content => @("END"),
          SLURMCTLD_OPTIONS="$slurmctld_options"
          | END
    }
  } else {
    file { "/etc/sysconfig/slurmctld":
      before  => Service["slurmctld"],
      ensure  => absent;
    }
  }

  service{'slurmctld':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    subscribe => $refresh_service ? { true  => [ Package['slurm'], File[$slurm::config::required_files] ],
                                      false => [ Package['slurm']                                       ],
                                    };
  }

  if ($slurm::config::open_firewall) {
    firewall{ '200 open slurmctld port':
      action => 'accept',
      dport  => $slurm::config::slurmctld_port,
      proto  => 'tcp',
    }
  }
}
