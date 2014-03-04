class base {
  include epel

  package { ['tmux', 'elinks', 'htop']:
    ensure  => present,
    require => Class['epel'],
  }
}
