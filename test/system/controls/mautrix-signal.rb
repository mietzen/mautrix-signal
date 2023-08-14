title "Maurirx-Signal System Test"

describe processes(Regexp.new("python3")) do
  it { should exist }
  its('users') { should include '1337' }
  its('pids') { should cmp "1"}
end

describe processes(Regexp.new("java")) do
  it { should exist }
  its('users') { should include '1337' }
  its('pids') { should cmp "7"}
end