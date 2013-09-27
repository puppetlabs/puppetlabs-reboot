file { 'c:/before.txt':
  content   => 'one',
  before    => File['c:/after.txt']
}

reboot { 'now':
  prompt    => true,
  subscribe => File['c:/before.txt']
}

file { 'c:/after.txt':
  content   => 'two'
}
