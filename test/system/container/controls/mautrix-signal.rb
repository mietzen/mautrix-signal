title "Maurirx-Signal System Test"

describe processes(Regexp.new("python3")) do
  it { should exist }
  its('users') { should include '1337' }
  its('pids') { should cmp "1"}
end

describe processes(Regexp.new("java")) do
  it { should exist }
  # TODO: run as non-root user
  # its('users') { should include '1337' }
  its('users') { should include 'root' }
  its('pids') { should_not cmp "1"}
end

describe port(29328) do
  its('protocols') { should include 'tcp' }
  its('addresses') { should include '0.0.0.0' }
end