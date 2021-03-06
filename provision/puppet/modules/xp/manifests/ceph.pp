class xp::ceph {

  class {
    '::ceph':
      version => 'emperor';
    #version => 'firefly';
  }

  $node_description = hiera_hash('node_description')
  $osd_devices = $node_description['osd']
  $fs = hiera('filesystem')
  $fsid = hiera('ceph_fsid')
  $nodes = hiera_array('ceph_nodes')
  $monitor = hiera('ceph_monitor')
  $mds = hiera('ceph_mds')
  $vlan_id = hiera('vlan')
  $cluster_network_interface = hiera('cluster_network_interface')
  $path = '/var/lib/ceph'

  package {
    ['xfsprogs', 'parted']:
      ensure => installed;
  }

  #file {
    #$path:
      #ensure => directory,
      #mode   => '0644',
      #owner  => root,
      #group  => root
  #}

  file {
    '/etc/ceph/ceph.conf':
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => template('xp/ceph/ceph.conf.erb'),
      require => Package['ceph'];
    '/root/.ssh/id_rsa':
      ensure => file,
      mode   => '0600',
      owner  => root,
      group  => root,
      source => "puppet://${puppetmaster}/xpfiles/id_rsa_ceph";
    '/root/.ssh/id_rsa.pub':
      ensure => file,
      mode   => '0644',
      owner  => root,
      group  => root,
      source => "puppet://${puppetmaster}/xpfiles/id_rsa_ceph.pub";
    '/etc/ceph/ceph.client.admin.keyring':
      ensure  => file,
      mode    => '0600',
      owner   => root,
      group   => root,
      source  => "puppet://${puppetmaster}/xpfiles/ceph.client.admin.keyring",
      require => Package['ceph'];
  }

  exec {
    'cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys':
      path    => "/usr/bin:/usr/sbin:/bin",
      user    => root,
      group   => root,
      unless  => 'grep ceph /root/.ssh/authorized_keys',
      require => File['/root/.ssh/id_rsa.pub'];
  }

}
