# slurm/workernode/config.pp
#
# Ensures that the slurmd service is running and restarted if the configuration file is modified.
#
# version 20170816
#
# Copyright (c) CERN, 2016-2017
# Authors: - Philippe Ganz <phganz@cern.ch>
#          - Carolina Lindqvist <calindqv@cern.ch>
#          - Pablo Llopis <pablo.llopis@cern.ch>
# License: GNU GPL v3 or later.
#

class slurm::workernode::config (
  Optional[String] $slurmd_options = undef,
  Boolean $manage_slurmd = true,
  Boolean $refresh_service = true,
) {
  if $manage_slurmd {
    if $slurmd_options {
      file { "/etc/sysconfig/slurmd":
      before  => Service["slurmd"],
        content => @("END"),
           SLURMD_OPTIONS="$slurmd_options"
           | END
      }
    } else {
      file { "/etc/sysconfig/slurmd":
        before  => Service["slurmd"],
        ensure  => absent;
      }
    }
  }
  service{'slurmd':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    subscribe => $refresh_service ? { true  => [ Package['slurm'], File[$slurm::config::required_files] ],
                                      false => [ Package['slurm']                                       ],
                                    };
  }

  if ($slurm::config::open_firewall) {
    firewall{ '201 open slurmd port':
      action => 'accept',
      dport  => $slurm::config::slurmd_port,
      proto  => 'tcp',
    }
  }
}
